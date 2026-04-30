{ ... }:

{
  programs.plasma = {
    input = {
      mice = [
        {
          acceleration = 1;
          accelerationProfile = "default";
          enable = true;
          leftHanded = false;
          name = "Logitech USB Receiver Mouse";
          naturalScroll = false;
          productId = "C548";
          scrollSpeed = 1;
          vendorId = "046D";
        }
      ];
      touchpads = [ 
        {
          disableWhileTyping = true;
          enable = true;
          middleButtonEmulation = true;
          name = "SYNA8020:00 06CB:CE5C Touchpad";
          naturalScroll = true;
          pointerSpeed = 0;
          productId = "CE5C";
          tapToClick = true;
          vendorId = "06CB";
        } 
      ];
    };
    kscreenlocker.appearance.wallpaper = ../../../../../assets/wallpapers/wallpaper1.jpg;
    workspace.wallpaper = ../../../../../assets/wallpapers/wallpaper1.jpg;
  };
}
