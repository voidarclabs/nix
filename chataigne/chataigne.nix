{ pkgs, pinnedPkgs, ... }:

let
  # 1. Define the AppImage source.
  appImageSrc = ./Chataigne-linux-x64-bleedingedge.AppImage;

  # 2a. Libraries pulled from the modern, current Nixpkgs (for small size).
  modernLibs = with pkgs; [
    alsa-lib
    freetype
    libglvnd
    curl
    SDL2
    hidapi
    xorg.libXrandr
  ];

  # 2b. Libraries pulled from the older, pinned package set (ONLY the ones that failed).
  pinnedCurlLibs = with pinnedPkgs; [
    curlWithGnuTls # This is the critical component for the CURL_GNUTLS_3 symbol.
    gnutls
  ];

  # 3. Combine the modern runtime dependencies with the pinned compatibility libraries.
  appImageDeps = [
    pkgs.steam-run
    pkgs.stdenv.cc.cc.lib # Ensures the modern C++ runtime is available
  ] ++ modernLibs ++ pinnedCurlLibs;

  chataigneDesktopItem = {
    desktopName = "Chataigne";
    name = "chataigne";
    exec = "chataigne"; # The name of the wrapper script in $out/bin
    icon = "chataigne"; # The name of the icon file (without extension)
    genericName = "Creative Control Software";
    comment = "Control and experiment with creative applications, hardware, and media.";
    categories = [ "AudioVideo" "Development" ];
  };

in

# 4. Create the final runnable derivation
pkgs.stdenv.mkDerivation {
  pname = "chataigne-runner";
  version = "1.0";

  # --- Attributes needed for AppImage running (not compiling) ---
  src = ./.;
  dontUnpack = true;
  dontBuild = true;
  # --------------------------------------------------

  # Inject the combined dependencies into the environment
  buildInputs = appImageDeps;

  # The install phase creates an executable wrapper script, extracts the AppImage,
  # and now handles the desktop file and icon.
  installPhase = ''
    mkdir -p $out/bin
    
    # --- STRATEGY: Extract AppImage contents to bypass FUSE, then fix LD_LIBRARY_PATH ---
    echo "Extracting AppImage contents to bypass FUSE requirement..."
    
    # Use the absolute Nix Store path of the AppImage
    ${appImageSrc} --appimage-extract
    echo "appimage extracted"
    
    # 2. Check if extraction worked and move the content to $out
    if [ ! -d "squashfs-root" ]; then
      echo "Extraction failed. The AppImage may not support --appimage-extract."
      exit 1
    fi
    
    # 2. CRITICAL FIX: Manually create and install the .desktop file
    mkdir -p $out/share/applications
    
    # pkgs.lib.makeDesktopItem takes the metadata and creates a small derivation
    # We copy the resulting .desktop file from that derivation's output path ($desktop_file_path)
    local desktop_file_path="${pkgs.makeDesktopItem chataigneDesktopItem}"

    # The file is typically named $name.desktop inside the share/applications folder of the new derivation
    cp $desktop_file_path/share/applications/chataigne.desktop $out/share/applications/

    # Copy the extracted contents into the output directory
    cp -r squashfs-root $out/

    # --- DESKTOP ENTRY & ICON (NEW) ---
    echo "Processing icon and desktop file..."

    # AppImages usually place the icon in squashfs-root/.DirIcon or similar
    # We will assume it's in the root of the extracted content.
    local icon_source="$out/squashfs-root/.DirIcon"
    local icon_target="$out/share/icons/hicolor/128x128/apps/chataigne.png" # Standard location
    
    # Use the icon if it exists (AppImages often use a .png or .svg)
    if [ -f "$icon_source" ]; then
        mkdir -p "$(dirname "$icon_target")"
        cp "$icon_source" "$icon_target"
    else
        echo "Warning: Could not find icon at $icon_source. Using default/no icon."
    fi
    # ----------------------------------

    # 3. Create the 'chataigne' executable wrapper
    cat > $out/bin/chataigne << EOF
#!${pkgs.stdenv.shell}
    
# The LD_LIBRARY_PATH is created using all dependencies (excluding the wrapper 'steam-run').
# This ensures the AppImage finds the pinned CURL library.
export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath (pkgs.lib.remove pkgs.steam-run appImageDeps)}:$LD_LIBRARY_PATH"

# Use steam-run to launch the main execution script inside the extracted folder.
exec ${pkgs.steam-run}/bin/steam-run "$out/squashfs-root/AppRun" "\$@"
EOF
    
    chmod +x $out/bin/chataigne
  '';
  
  meta = {
    description = "Declarative runner for the Chataigne AppImage, providing necessary dependencies.";
    homepage = "https://chataigne.io/"; # Example: Add the actual homepage
    license = pkgs.lib.licenses.unfree; # AppImages are often proprietary/unfree
    platforms = [ "x86_64-linux" ];
  };
}
