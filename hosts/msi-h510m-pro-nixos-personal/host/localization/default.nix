{ lib, ... }:

{
  console = {
    font = "eurlatgr";
    keyMap = lib.mkForce "us";
    useXkbConfig = false;
  };
  time = {
    hardwareClockInLocalTime = false;
    timeZone = "Europe/Istanbul";
  };
}
