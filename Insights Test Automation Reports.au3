#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseUpx=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;#RequireAdmin
;#AutoIt3Wrapper_usex64=n
#include <SQLite.au3>
#include <SQLite.dll.au3>
#include <Toast.au3>
#include <JanisonTestAutomationReports.au3>

Local $app_name = "Insights Test Automation Reports"

; Authentication

Local $ini_filename = @ScriptDir & "\" & $app_name & ".ini"
_TestRailAuthenticationWithToast($app_name, "https://janison.testrail.com", $ini_filename)
_ConfluenceAuthenticationWithToast($app_name, "https://janisoncls.atlassian.net", $ini_filename)
_ConfluenceAuthenticationWithToast($app_name, "https://janisoncls.atlassian.net", $ini_filename)

; Startup SQLite

_SQLite_Startup()
ConsoleWrite("_SQLite_LibVersion=" & _SQLite_LibVersion() & @CRLF)
FileDelete(@ScriptDir & "\" & $app_name & ".sqlite")
_SQLite_Open(@ScriptDir & "\" & $app_name & ".sqlite")
_SQLite_Exec(-1, "PRAGMA synchronous = OFF;")		; this should speed up DB transactions
_SQLite_Exec(-1, "CREATE TABLE SavedRuntime (CreatedOn,Test,SavedRuntime integer);") ; CREATE a Table
_SQLite_Exec(-1, "CREATE TABLE SavedCases (Test,SavedCases integer);") ; CREATE a Table
_SQLite_Exec(-1, "CREATE TABLE Bug (Key,Created,Priority);") ; CREATE a Table

; Page header

$storage_format = '<a href=\"https://github.com/seanhaydongriffin/Insights-Test-Automation-Reports/releases/download/v0.1/Insights.Test.Automation.Reports.portable.exe\">Click to update Insights reports</a><br /><br />'

; Reports

ManualRunTimeSavedReport($app_name, 49, "Insights ", " SIT")
ManualTestCasesSavedReport($app_name, 49, "Insights - ")
DefectsRaisedReport($app_name, "project = INS AND issuetype = Bug AND labels = Automation AND labels = Insights", 1)
DefectsListReport("project = INS AND issuetype = Bug AND labels = Automation AND labels = Insights")

; Update Confluence

_Toast_Show(0, $app_name, "Uploading reports to confluence", -300, False, True)
Update_Confluence_Page("https://janisoncls.atlassian.net", "JAST", "469664600", "469664606", $app_name, $storage_format)

; Shutdown

_JiraShutdown()
_SQLite_Close()
_SQLite_Shutdown()
_Toast_Show(0, $app_name, "Done. Refresh the page in Confluence.", -3, False, True)
Sleep(3000)
