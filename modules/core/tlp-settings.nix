{
  CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
  CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
  
  CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
  CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
  
  CPU_BOOST_ON_AC = 1;
  CPU_BOOST_ON_BAT = 0;

  # Platform Profiles (Replacing ryzenadj)
  PLATFORM_PROFILE_ON_AC = "performance";
  PLATFORM_PROFILE_ON_BAT = "low-power";

  PCIE_ASPM_ON_AC = "default";
  PCIE_ASPM_ON_BAT = "powersave";

  MAX_LOST_WORK_SECS_ON_AC = 15;
  MAX_LOST_WORK_SECS_ON_BAT = 60;
  
  NMI_WATCHDOG = 0;
}
