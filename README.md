# FFmpeg Media File Converter

FFmpeg Media File Converter is an open-source application developed with AutoHotkey v2.0. It provides an intuitive graphical interface for converting media files using FFmpeg. Users can easily select files, customize FFmpeg parameters, and monitor the conversion process.

![Main Interface Screenshot](https://github.com/akcansoft/FFmpeg-Media-File-Converter/blob/main/ss-1.png)
![Conversion Status Screenshot](https://github.com/akcansoft/FFmpeg-Media-File-Converter/blob/main/ss-2.png)

## Features

- **Drag-and-Drop Support**: Quickly add files by simply dragging and dropping them into the application.
- **Resizable Interface**: Resize the application window to suit your preferences.
- **File List Management**: Add, remove, or clear files from the conversion list.
- **Customizable FFmpeg Parameters**: Specify FFmpeg parameters for advanced control over the conversion process.
- **Output Format Selection**: Choose the desired output file extension.
- **Conversion Progress Monitoring**: View the status of each file and overall progress in a dedicated status window.
- **Cancel Ongoing Conversions**: Stop the conversion process at any time.
- **Command line parameters** : Allows users to add files for conversion by passing them as command line arguments when launching the application.

## Requirements

- **FFmpeg**: Ensure FFmpeg is installed on your system. You can download it from [FFmpeg.org](https://ffmpeg.org/). After downloading, extract the files and note the path to `ffmpeg.exe`.
- **AutoHotkey v2.0**: To review and run the source code [MediaFileConverter.ahk](https://github.com/akcansoft/FFmpeg-Media-File-Converter/blob/MediaFileConverter.ahk), AutoHotkey v2.0 must be installed. Download it from [AutoHotkey.com](https://www.autohotkey.com/).  
  Note: AutoHotkey installation is not required to run the `MediaFileConverter.exe` file.

## Installation

1. Download `MediaFileConverter.exe` file
2. Ensure FFmpeg is installed and note its file path (e.g., `C:\Program Files\FFmpeg\bin\ffmpeg.exe`).
3. Place the `MediaFileConverter.exe` file in a convenient location and double-click to run it.

## Usage

- Launch the application by running the `MediaFileConverter.exe` file.
- Drag and drop media files into the application or use the "Add File" button to select files.
- Specify the FFmpeg executable path if it is not already set.
- Customize the FFmpeg parameters and output file extension as needed.
- Click the "Convert" button to start the conversion process.
- Monitor the progress in the status window. You can cancel the conversion at any time.

## License

This project is licensed under the GNU AFFERO GENERAL PUBLIC License, which ensures that the source code remains open and accessible. See the [LICENSE](LICENSE) file for details.

## Author

- **Mesut Akcan**  
  - [GitHub](https://github.com/akcansoft)  
  - [YouTube](https://youtube.com/mesutakcan)  
  - [Blog](https://mesutakcan.blogspot.com)  

## Contributing

Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Commit your changes and push them to your fork.
4. Open a pull request with a detailed description of your changes.
