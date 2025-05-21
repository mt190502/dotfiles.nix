{ lib, ... }:
{
  console = {
    font = "eurlatgr";
    keyMap = lib.mkForce "us";
    useXkbConfig = false;
  };
  time = {
    hardwareClockInLocalTime = true;
    timeZone = "Europe/Istanbul";
  };
}
