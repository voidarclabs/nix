# resolve/default.nix
{
  pkgs-unstable,
  inputs,
  lib,
  ...
}:

let
  studio-variant = true;
  mesa-good-pkg = inputs.mesa-davinci.legacyPackages.x86_64-linux.mesa;
  pkgs-unstable =
    import
      (builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
      })
      {
        config = {
          allowUnfree = true;
        };
      };
  original =
    if studio-variant then pkgs-unstable.davinci-resolve-studio else pkgs-unstable.davinci-resolve;
  davinci-unwrapped = original.passthru.davinci;

  ffmpeg-encoder-plugin = pkgs-unstable.stdenv.mkDerivation (finalAttrs: {
    pname = "ffmpeg-encoder-plugin";
    version = "1.2.1";

    src = pkgs-unstable.fetchFromGitHub {
      owner = "EdvinNilsson";
      repo = "ffmpeg_encoder_plugin";
      rev = "v${finalAttrs.version}";
      hash = "sha256-F4Q8YCXD5UldTwLbWK4nHacNPQ/B+4yLL96sq7xZurM=";
    };

    nativeBuildInputs = [ pkgs-unstable.cmake ];
    buildInputs = [ pkgs-unstable.ffmpeg-full ];

    installPhase = ''
      mkdir -p $out
      cp ffmpeg_encoder_plugin.dvcp $out/
    '';
  });

  aac-encoder-plugin = pkgs-unstable.stdenv.mkDerivation {
    pname = "aac-encoder-plugin";
    version = "1.0.1";
    src = pkgs-unstable.fetchFromGitHub {
      owner = "Toxblh";
      repo = "davinci-linux-aac-codec";
      rev = "v1.0.1";
      hash = "sha256-NVNxmUFNwZ3hzlyi3QVENXhfPICAAP3M4s6QEgWsP/g=";
    };

    nativeBuildInputs = [
      pkgs-unstable.clang
      pkgs-unstable.gnumake
    ];
    buildInputs = [
      pkgs-unstable.ffmpeg-full.dev
      pkgs-unstable.ffmpeg-full.lib
    ];

    dontConfigure = true;
    buildPhase = ''
      make clean
      make CC=${pkgs-unstable.clang}/bin/clang++
    '';
    installPhase = ''
      mkdir -p $out
      if [ -f bin/aac_encoder_plugin.dvcp ]; then
        cp bin/aac_encoder_plugin.dvcp $out/
      else
        cp aac_encoder_plugin.dvcp $out/
      fi
    '';
  };

  davinci-with-plugin =
    pkgs-unstable.runCommand
      "${davinci-unwrapped.pname}-with-ffmpeg-plugin-${davinci-unwrapped.version}"
      { }
      ''
        cp -a ${davinci-unwrapped} $out
        chmod -R u+w $out
        mkdir -p $out/IOPlugins/ffmpeg_encoder_plugin.dvcp.bundle/Contents/Linux-x86-64
        cp ${ffmpeg-encoder-plugin}/ffmpeg_encoder_plugin.dvcp \
          $out/IOPlugins/ffmpeg_encoder_plugin.dvcp.bundle/Contents/Linux-x86-64/
        mkdir -p $out/IOPlugins/aac_encoder_plugin.dvcp.bundle/Contents/Linux-x86-64
        cp ${aac-encoder-plugin}/aac_encoder_plugin.dvcp \
          $out/IOPlugins/aac_encoder_plugin.dvcp.bundle/Contents/Linux-x86-64/
      '';

  davinci = davinci-with-plugin;

  davinci-fixed = pkgs-unstable.buildFHSEnv {
    pname = davinci-unwrapped.pname;
    version = davinci-unwrapped.version;

    # original.extraPreBwrapCmds is exposed, but it does not respect our studio-variant flag, so we inline it here:
    extraPreBwrapCmds = lib.optionalString studio-variant ''
      mkdir -p ~/.local/share/DaVinciResolve/license || exit 1
      mkdir -p ~/.local/share/DaVinciResolve/Extras || exit 1
    '';

    # original.extraBwrapArgs is exposed, but it does not respect our studio-variant flag, so we inline it here:
    extraBwrapArgs = lib.optionals studio-variant [
      ''--bind "$HOME"/.local/share/DaVinciResolve/license ${davinci}/.license''
      ''--bind "$HOME"/.local/share/DaVinciResolve/Extras ${davinci}/Extras''
    ];

    extraBuildCommands = ''
      mkdir -p opt
      ln -s ${davinci} opt/resolve
    '';

    runScript = "${pkgs-unstable.bash}/bin/bash ${pkgs-unstable.writeText "davinci-wrapper-goodmesa" ''
      export QT_XKB_CONFIG_ROOT="${pkgs-unstable.xkeyboard_config}/share/X11/xkb"
      export QT_PLUGIN_PATH="${davinci}/libs/plugins:$QT_PLUGIN_PATH"

      export LD_LIBRARY_PATH=${pkgs-unstable.ffmpeg-full.lib}/lib:${pkgs-unstable.shaderc.lib}/lib:${pkgs-unstable.vulkan-loader}/lib:${pkgs-unstable.stdenv.cc.cc.lib}/lib:${mesa-good-pkg}/lib:${mesa-good-pkg}/lib/dri:$LD_LIBRARY_PATH
      export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib:/usr/lib32:${davinci}/libs
      export LD_PRELOAD=${pkgs-unstable.shaderc.lib}/lib/libshaderc_shared.so.1''${LD_PRELOAD:+:$LD_PRELOAD}

      exec ${davinci}/bin/resolve
    ''}";

    # we inline extraInstallCommands instead of referencing orig.extraInstallCommands, as it is not exposed
    extraInstallCommands = ''
      mkdir -p $out/share/applications $out/share/icons/hicolor/128x128/apps
      ln -s ${davinci}/share/applications/*.desktop $out/share/applications/
      ln -s ${davinci}/graphics/DV_Resolve.png $out/share/icons/hicolor/128x128/apps/davinci-resolve${lib.optionalString studio-variant "-studio"}.png
    '';

    # we inline targetpkgs instead of referencing orig.targetpkgs, as it is not exposed
    targetPkgs = pkgs-unstable: [
      # our addition:
      mesa-good-pkg

      # original dependencies:
      pkgs-unstable.alsa-lib
      pkgs-unstable.aprutil
      pkgs-unstable.bzip2
      davinci
      pkgs-unstable.dbus
      pkgs-unstable.expat
      pkgs-unstable.ffmpeg-full
      pkgs-unstable.ffmpeg-full.lib
      pkgs-unstable.fontconfig
      pkgs-unstable.freetype
      pkgs-unstable.glib
      pkgs-unstable.shaderc.lib
      pkgs-unstable.stdenv.cc.cc.lib
      pkgs-unstable.libGL
      pkgs-unstable.libGLU
      pkgs-unstable.libarchive
      pkgs-unstable.libcap
      pkgs-unstable.librsvg
      pkgs-unstable.libtool
      pkgs-unstable.libuuid
      pkgs-unstable.libxcrypt
      pkgs-unstable.libxkbcommon
      pkgs-unstable.nspr
      pkgs-unstable.ocl-icd
      pkgs-unstable.opencl-headers
      pkgs-unstable.python3
      pkgs-unstable.python3.pkgs.numpy
      pkgs-unstable.udev
      pkgs-unstable.vulkan-loader
      pkgs-unstable.xdg-utils
      pkgs-unstable.xorg.libICE
      pkgs-unstable.xorg.libSM
      pkgs-unstable.xorg.libX11
      pkgs-unstable.xorg.libXcomposite
      pkgs-unstable.xorg.libXcursor
      pkgs-unstable.xorg.libXdamage
      pkgs-unstable.xorg.libXext
      pkgs-unstable.xorg.libXfixes
      pkgs-unstable.xorg.libXi
      pkgs-unstable.xorg.libXinerama
      pkgs-unstable.xorg.libXrandr
      pkgs-unstable.xorg.libXrender
      pkgs-unstable.xorg.libXt
      pkgs-unstable.xorg.libXtst
      pkgs-unstable.xorg.libXxf86vm
      pkgs-unstable.xorg.libxcb
      pkgs-unstable.xorg.xcbutil
      pkgs-unstable.xorg.xcbutilimage
      pkgs-unstable.xorg.xcbutilkeysyms
      pkgs-unstable.xorg.xcbutilrenderutil
      pkgs-unstable.xorg.xcbutilwm
      pkgs-unstable.xorg.xkeyboardconfig
      pkgs-unstable.zlib
    ];

    passthru = original.passthru;
    meta = original.meta;
  };
in
{
  environment.systemPackages = with pkgs-unstable; [ davinci-fixed ];
}
