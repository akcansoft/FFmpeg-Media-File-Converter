/*
FFmpeg Media File Converter
Open source utility that converts media files using FFmpeg.
=============================
Mesut Akcan
makcan@gmail.com
youtube.com/mesutakcan
mesutakcan.blogspot.com
github.com/akcansoft
=============================
v1.0 R16
06/04/2025
=============================
*/
#Requires AutoHotkey v2.0

FFMpegPath := "C:\Program Files\FFmpeg\bin\ffmpeg.exe"
margin := 10
g1Dim := { w: 600, h: 500 } ; Main Gui size
g2Dim := { w: 600, h: 350 } ; Status Gui size
cancelConvert := false ; Flag to cancel conversion

appName := "FFmpeg Media File Converter"
appVer := "v1.0"

; ---- Main gui ------------------
g1 := Gui("+Resize", appName)
g1.MarginX := g1.MarginY := margin

; --- ListView ---
LV1 := g1.AddListView("xm ym h" g1Dim.h - 140, ["File Path", "File Name"])
LV1.OnEvent("ItemSelect", UpdateButtons)
LV1.OnEvent("ContextMenu", ShowContextm)

; FFmpeg selection
txtFFmpeg := g1.AddText("xm y+10", "FFmpeg.exe:")
edtFFmpeg := g1.AddEdit("x+10 w350", FFMpegPath)

btnBrowse := g1.AddButton("x+10", "...")
btnBrowse.OnEvent("Click", BrowseFFmpeg)

txtFFmpegParams := g1.AddText("xm y+15", "FFmpeg Parameters:")
edtFFmpegParams := g1.AddEdit("x+10 yp-5 w200", "-acodec pcm_s16le")

btnFFmpegHlp := g1.AddButton("x+1", "?") ; Help button for FFmpeg
btnFFmpegHlp.OnEvent("Click", (*) => Run("https://ffmpeg.org/ffmpeg.html"))

txtOutputExt := g1.AddText("x+10 yp+5", "Output Extension:")
edtOutputExt := g1.AddEdit("x+10 yp-5", "wav")

btnAdd := g1.AddButton("xm", "Add &File")
btnAdd.OnEvent("Click", AddFiles)

btnRemove := g1.AddButton("x+10 Disabled", "&Remove from List")
btnRemove.OnEvent("Click", RemoveSelected)

btnConvert := g1.AddButton("x+10 Disabled", "&Convert")
btnConvert.OnEvent("Click", ConvertFiles)

btnExit := g1.AddButton("x+300", "&Exit")
btnExit.OnEvent("Click", g1Close)

; --- Status Bar -------
SB1 := g1.AddStatusBar()
SB1.SetText("You can drag and drop files.")

; --- Events ------
g1.OnEvent("DropFiles", DropFiles) ; File drag and drop
g1.OnEvent("Size", g1Size) ; Resize event
g1.OnEvent("Close", g1Close) ; Close event

; --- Menu ---
fileMenu := Menu() ; Main menu
AddMenuItems(fileMenu)
fileMenu.Add() ; Separator
fileMenu.Add("&Exit`tAlt+F4", g1Close)
rcMenu := Menu() ; Context menu
AddMenuItems(rcMenu)
helpMenu := Menu() ; Help menu
helpMenu.Add("&About", About)
mnuBar := MenuBar() ; Menu bar
mnuBar.Add("&File", fileMenu)
mnuBar.Add("&Help", helpMenu)
g1.MenuBar := mnuBar

; --------- Status gui -----------------------
g2 := Gui("+Resize", "Conversion Status") ; Status window
LV2 := g2.AddListView("w" g2Dim.w - 20 " h" g2Dim.h - 70, ["File", "Status", "New File"])
progressBar := g2.AddProgress("xm w" g2Dim.w - 2 * margin " h20 cGreen BackgroundAAAAAA")
progressTxt1 := g2.AddText("xm yp+3 w30 BackgroundTrans cffffff", "1/100")
progressTxt2 := g2.AddText("xm yp BackgroundTrans cffffff", "000%")

btnOK := g2.AddButton("xm y+10", "Cancel")
btnOK.OnEvent("Click", g2btnCancelCloseClick)
SB2 := g2.AddStatusBar()
g2.OnEvent("Size", g2Size)
g2.OnEvent("Close", g2Close) ; Close event
;--------------------------------------------

; --- Hotkeys ---
#HotIf WinActive("ahk_id " g1.Hwnd)
Del:: RemoveSelected()
Insert:: AddFiles()
^Enter:: ConvertFiles()
^a:: SelectAll(true)
Esc:: SelectAll(false)
#HotIf

; ---- Main program start -------------------
g1.Show("w" g1Dim.w " h" g1Dim.h)

; Add menu items to the context menu and the main menu
AddMenuItems(m) {
  m.Add("&Add File`tIns", AddFiles)
  m.Add() ; Separator
  m.Add("&Remove Selected from List`tDel", RemoveSelected)
  m.Add("&Clear List", ClearList)
  m.Add("C&onvert All`tCtrl+Enter", ConvertFiles)
  m.Add() ; Separator
  m.Add("&Select All`tCtrl+A", (*) => (SelectAll(true)))
  m.Add("&Deselect All`tEsc", (*) => (SelectAll(false)))
}

SelectAll(select) { ; Select all or deselect all items in the ListView.
  LV1.Modify(0, select ? "Select" : "-Select")
  UpdateButtons()
}

UpdateButtons(*) { ; Update the state of buttons based on the ListView selection.
  btnRemove.Enabled := LV1.GetNext() > 0
  btnConvert.Enabled := LV1.GetCount() > 0
}

; FFmpeg path selection
; This function allows the user to select the FFmpeg executable file.
BrowseFFmpeg(*) {
  g1.Opt("+OwnDialogs")
  if selectedFile := FileSelect(1, FFMpegPath, "Select FFmpeg", "FFmpeg (ffmpeg.exe)") {
    if FileExist(selectedFile) {
      edtFFmpeg.Value := selectedFile
    } else {
      MsgBox("The selected FFmpeg file could not be found.", "Error", "Icon!")
    }
  }
}

; Adds a file to the ListView if it is not already present.
AddFileToListView(filePath) {
  SplitPath(filePath, &fileName, &dir)
  if FindRowInListView(dir, fileName) {
    return false
  }
  LV1.Add("", dir, fileName)
  return true
}

; Checks if a file is already present in the ListView.
FindRowInListView(dir, fileName) {
  loop LV1.GetCount() {
    if (LV1.GetText(A_Index, 1) = dir && LV1.GetText(A_Index, 2) = fileName)
      return true
  }
  return false
}

; Clears the ListView and updates the buttons.
ClearList(*) {
  LV1.Delete()
  UpdateButtons()
}

; Adds files to the ListView using a file selection dialog.
AddFiles(*) {
  g1.Opt("+OwnDialogs")
  selectedFiles := FileSelect("M3", , "Select File")
  if !selectedFiles
    return

  duplicateCount := 0
  for file in selectedFiles {
    if !AddFileToListView(file)
      duplicateCount++
  }
  SB1Message(duplicateCount)
  UpdateButtons()
}

; Adds files to the ListView using drag-and-drop functionality.
DropFiles(gObj, gCtrlObj, FileArray, X, Y) {
  duplicateCount := 0
  for file in FileArray {
    if DirExist(file) {
      Loop Files, file "\*.*" {
        if !AddFileToListView(A_LoopFileFullPath)
          duplicateCount++
      }
    } else {
      if !AddFileToListView(file)
        duplicateCount++
    }
  }
  SB1Message(duplicateCount)
  UpdateButtons()
}

; Removes selected files from the ListView.
RemoveSelected(*) {
  while (row := LV1.GetNext()) {
    LV1.Delete(row)
  }
  SB1Message(0)
  UpdateButtons()
}

; Close the main GUI and exit the application.
g1Close(*) {
  ExitApp()
}

; Close the status GUI and cancel the conversion if necessary.
g2btnCancelCloseClick(*) {
  global cancelConvert
  ; Cancel button
  if btnOK.Text != "Close" {
    cancelConvert := true
    return
  }

  ; Close button
  g2Close()
}

g2Close(*) {
  cancelConvert := false
  btnOK.Text := "Cancel"
  LV2.Delete() ; Clear the status ListView
  g2.Hide() ; Hide the status window
  g1.Opt("-Disabled") ; Enable the main window
  g1.Show() ; Show the main window
}

; Converts files using FFmpeg based on the selected parameters.
ConvertFiles(*) {
  global cancelConvert
  ffmpegPath := Trim(edtFFmpeg.Text)
  if !FileExist(ffmpegPath) {
    MsgBox("ffmpeg.exe not found. Please specify a valid FFmpeg path.", "Error", "Icon!")
    return
  }

  g2.Show() ; Show the status window
  g2.Opt("+OwnDialogs") ; Allow the status window to own dialogs
  g2.Opt('+Owner' g1.hwnd) ; Set the owner of the status window to the main window
  g1.Opt('+Disabled') ; Disable the main window
  convertedCount := 0
  failedCount := 0
  totalFiles := LV1.GetCount()
  ext := Trim(edtOutputExt.Text)
  if !RegExMatch(ext, "^\.") {
    ext := "." ext
  }
  parameter := " " Trim(edtFFmpegParams.Text) " "

  loop totalFiles { ; Loop through all files in the ListView
    if cancelConvert {
      btnOK.Text := "Close"
      cancelConvert := false
      SB2.SetText("Conversion was canceled by the user.")
      return
    }
    LV1.Modify(0, "-Select") ; Deselect all items
    LV1.Modify(A_Index, "Select Vis") ; Select the current item

    fileDir := LV1.GetText(A_Index, 1) ; Get the directory of the file
    fileName := LV1.GetText(A_Index, 2) ; Get the file name
    SplitPath(fileName, , , , &fName) ; Split the file name to get the base name

    inputFile := fileDir "\" fileName ; Full path of the input file
    outputFile := fileDir "\" fName ext ; Full path of the output file

    UpdateProgress(A_Index, totalFiles)
    if FileExist(inputFile) { ; Check if the input file exists
      if !FileExist(outputFile) {
        cmd := '"' ffmpegPath '" -i "' inputFile '"' parameter '"' outputFile '"'
        LV2.Add("", inputFile, "Converting...")
        row := LV2.GetCount()
        LV2.Modify(0, "-Select") ; Deselect all items
        LV2.Modify(row, "Select Vis") ; Select the current item
        try {
          RunWait(cmd, , "Hide")
          if FileExist(outputFile) {
            LV2.Modify(row, , , "Converted", fName ext)
            convertedCount++
          } else {
            LV2.Modify(row, , , "ERROR: Conversion failed")
            failedCount++
          }
        } catch as err {
          LV2.Modify(row, , , "ERROR: " err.message)
          failedCount++
        }
      } else {
        LV2.Add("", inputFile, "FILE ALREADY EXISTS")
      }
    } else {
      LV2.Add("", inputFile, "ERROR: Source file not found")
      failedCount++
    }
  }
  SB2.SetText(Format("Process complete. Total files: {1}, Converted files: {2}, Failed: {3}", totalFiles, convertedCount, failedCount))
  btnOK.Text := "Close"
}

; Updates the status bar message with the number of duplicate files and total file count.
SB1Message(dupeCount) {
  if dupeCount > 0 {
    txt := dupeCount " files were not added because they are already in the list."
  }
  txt .= " Total file count: " LV1.GetCount()
  SB1.SetText(txt)
}

; ListView resizing function
ResizeListView(LV, gWidth, gHeight, r) {
  LV.Move(, , gWidth - 2 * margin, gHeight - r)
  LV.GetPos(, , &w, &h)
  colCount := LV.GetCount("Column")
  colWidths := colCount = 3 ? [0.5, 0.3, 0.2] : [0.7, 0.3]
  for i, width in colWidths {
    LV.ModifyCol(i, w * width - 15)
  }
  return h
}

; Main gui resizing
g1Size(gObj, MinMax, Width, Height) {
  if MinMax = -1  ; When window is minimized
    return

  ; Adjust ListView to new size
  h := ResizeListView(LV1, Width, Height, 140)

  txtFFmpeg.Move(, margin + h + 15)
  edtFFmpeg.Move(, margin + h + 10)
  btnBrowse.Move(, margin + h + 10)

  txtFFmpegParams.Move(, margin + h + 50)
  edtFFmpegParams.Move(, margin + h + 45)

  btnFFmpegHlp.Move(, margin + h + 45)

  txtOutputExt.Move(, margin + h + 50)
  edtOutputExt.Move(, margin + h + 45)

  btnAdd.Move(, margin + h + 75)
  btnRemove.Move(, margin + h + 75)
  btnConvert.Move(, margin + h + 75)

  btnExit.GetPos(, , &w)
  btnExit.Move(Width - w - margin, margin + h + 75)
  WinRedraw(gObj)
}

; Resizes the status window and its components.
g2Size(gObj, MinMax, Width, Height) {
  if MinMax = -1  ; When window is minimized
    return

  h := ResizeListView(LV2, Width, Height, 90)
  progressBar.Move(, h + 15, Width - 2 * margin)
  progressTxt1.Move(, h + 18)
  progressTxt2.GetPos(, , &w)
  progressTxt2.Move(Width / 2 - w / 2, h + 18)
  btnOK.GetPos(, , &w)
  btnOK.Move(Width / 2 - w / 2, margin + h + 30)
  WinRedraw(gObj)
}

; Context menu for the ListView
ShowContextm(LV1, Item, IsRightClick, X, Y) {
  rcMenu.Show(X, Y)
}

; Updates progress bar and text based on current file index and total files.
UpdateProgress(index, totalFiles) {
  percentage := Round(index / totalFiles * 100)
  progressBar.Value := percentage
  WinGetPos(, , &g2w, , g2.Hwnd)
  progressTxt1.Text := index "/" totalFiles
  progressTxt2.GetPos(, , &w)
  progressTxt2.Move(g2w / 2 - w / 2)
  progressTxt2.Text := percentage "%"
}

; About dialog
About(*) {
  MsgBox(Format("
(
{1}
{2}

©2025
Mesut Akcan
makcan@gmail.com

akcansoft.blogspot.com
mesutakcan.blogspot.com
github.com/akcansoft
youtube.com/mesutakcan
)",
  appName, appVer), "About", "Owner" g1.Hwnd)
}
