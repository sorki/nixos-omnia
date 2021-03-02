{ buildUBoot
, lib
, python
, fetchpatch
, fetchFromGitLab
, fetchFromGitHub
}:
(buildUBoot {
  defconfig = "turris_omnia_defconfig";
  extraMeta.platforms = ["armv7l-linux"];
  filesToInstall = [
    "u-boot-spl.kwb"
    "tools/kwboot"
    ".config"
  ];

  extraPatches = [ ];
})
.overrideAttrs(oldAttrs: {
  postPatch = oldAttrs.postPatch + ''
    sed -i '~s~define MAX_TFTP_PATH_LEN 127~define MAX_TFTP_PATH_LEN 512~' cmd/pxe.c
    cat cmd/pxe.c
  '';

  src = fetchFromGitLab {
    domain = "gitlab.nic.cz";
    owner = "turris";
    repo = "turris-omnia-uboot";
    sha256 = "1ndmsk7qwsy73c1y8gl8bxh450d9clyq58yy7md9pf5c0w42vjfb";
    rev = "omnia-2019";
  };
})
