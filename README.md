# WhatsApp Status Picker
A Flutter app to browse, preview, and save WhatsApp status images and videos. Built with an MVC architecture, it offers a user-friendly tabbed interface, media previews, and downloads to a custom gallery album. Supports dark/light mode toggling and requires storage permissions to access WhatsApp status directories.

## Features
- Tabbed Interface: Separate tabs for images and videos using PictureSP and VideoSP.
- Media Previews: Tap to view full-size images or play videos in a dialog with play/pause controls.
- Download Media: Save statuses to a "WA Status Picker" gallery album with a single tap.
- Theme Switching: Toggle between dark and light modes for better usability.
- MVC Architecture: Organized into Model (status_model.dart), View (main.dart), and Controller (status_controller.dart) for maintainability.
- Permission Handling: Requests storage permissions to access WhatsApp status files.

## Screenshots
### Logo
<img src="https://github.com/user-attachments/assets/dc3b0d43-1e9a-4cbb-b9d8-e84bd154d348" width="360" height="720">

### Main Screens 
#### Without Permission
<img src="https://github.com/user-attachments/assets/258387ad-de79-4832-a1de-71876acb0dc5" width="360" height="720">
<img src="https://github.com/user-attachments/assets/03a34b63-8426-427f-a7e3-2d5bda483bc7" width="360" height="720">

#### With Permission
##### Photos
<img src="https://github.com/user-attachments/assets/7372facd-5c54-427d-92a0-5fc414a985cd" width="360" height="720">

##### Videos
<img src="https://github.com/user-attachments/assets/a6054eb7-350a-4415-ada0-ceaf2f69ca55" width="360" height="720">

#### Dialogs
##### Refresing 
<img src="https://github.com/user-attachments/assets/64a3eb85-0ed6-4d2b-9bf5-dd2bb8bbedf9" width="360" height="720">

##### Permission Denied
<img src="https://github.com/user-attachments/assets/abf26c96-90aa-4bb1-b814-05bb9a5c9926" width="360" height="720">

##### Video Playback
<img src="https://github.com/user-attachments/assets/e9af7615-9e63-425a-bc37-d68ec4ce2ada" width="360" height="720">

##### Media Picked Succesfully
<img src="https://github.com/user-attachments/assets/83619f66-5d81-4f5e-bbd5-4ffb066fa049" width="360" height="720">

## Usage
- Install the APK on an Android device with WhatsApp installed.
- Grant storage permissions when prompted to access /storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses/.
- Browse the Pictures tab for images or the Videos tab for videos.
- Tap a thumbnail to preview:
  - Images: View full-size in a dialog with a download button.
  - Videos: Play in a dialog with play/pause controls and a download button.
- Tap the download button to save media to the "WA Status Picker" gallery album.
- Use the refresh button to update the status list.
- Toggle dark/light mode via the theme button in the app bar.

## Instalation
You can get the first release here:
https://github.com/JoeSherif97/WA-Status-Picker/releases/tag/Release-1.0
