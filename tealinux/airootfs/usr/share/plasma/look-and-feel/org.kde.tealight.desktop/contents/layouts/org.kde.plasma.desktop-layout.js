var allPanels = panels();
for (var i = 0; i < allPanels.length; i++) {
    allPanels[i].remove();
}

// =========================================================
// 1. WALLPAPER
// =========================================================
var allDesktops = desktops();
for (var i = 0; i < allDesktops.length; i++) {
    var d = allDesktops[i];
    d.wallpaperPlugin = "org.kde.image";
    d.currentConfigGroup = ["Wallpaper", "org.kde.image", "General"];
    d.writeConfig("Image", "file:///usr/share/backgrounds/tea-light.png");
}

// =========================================================
// 2. TOP BAR
// =========================================================
var panelTop = new Panel();
panelTop.location = "top";
panelTop.height = 32;
panelTop.floating = true;
panelTop.lengthMode = "fill";
panelTop.hiding = "none";

// -- Left Spacer --
var paddingLeft = panelTop.addWidget("org.kde.plasma.panelspacer");
paddingLeft.currentConfigGroup = ["General"];
paddingLeft.writeConfig("expanding", "false");
paddingLeft.writeConfig("length", "12");

// -- Kickoff & Global Menu --
panelTop.addWidget("org.kde.plasma.kickoff");
panelTop.addWidget("org.kde.plasma.marginsseparator");
panelTop.addWidget("org.kde.plasma.appmenu");

// -- Middle Spacer --
panelTop.addWidget("org.kde.plasma.panelspacer");

// -- System Tray --
var systray = panelTop.addWidget("org.kde.plasma.systemtray");
try {
    systray.currentConfigGroup = ["General"];
    systray.writeConfig("iconSpacing", "6");
    systray.reloadConfig();
} catch (e) {
    print("Tray config skipped");
}

panelTop.addWidget("org.kde.plasma.marginsseparator");

// -- Digital Clock --
var clock = panelTop.addWidget("org.kde.plasma.digitalclock");
clock.currentConfigGroup = ["Appearance"];
clock.writeConfig("showDate", "false");
clock.writeConfig("showSeconds", "false");
clock.writeConfig("boldText", "true");
clock.writeConfig("fontStyleName", "Bold");
clock.writeConfig("fontWeight", "700");
clock.writeConfig("autoFontAndSize", "false");
clock.writeConfig("fontSize", "11");
clock.writeConfig("dateFormat", "custom");

// -- Right Spacer --
var paddingRight = panelTop.addWidget("org.kde.plasma.panelspacer");
paddingRight.currentConfigGroup = ["General"];
paddingRight.writeConfig("expanding", "false");
paddingRight.writeConfig("length", "12");


// =========================================================
// 3. BOTTOM DOCK
// =========================================================
var panelBottom = new Panel();
panelBottom.location = "bottom";
panelBottom.alignment = "center";
panelBottom.height = 60;
panelBottom.floating = true;
panelBottom.lengthMode = "fit";
panelBottom.hiding = "dodgewindows";

// -- Dock Padding Left --
var dockPaddingLeft = panelBottom.addWidget("org.kde.plasma.panelspacer");
dockPaddingLeft.currentConfigGroup = ["General"];
dockPaddingLeft.writeConfig("expanding", "false");
dockPaddingLeft.writeConfig("length", "8");

// -- Task Manager (Icons Only) --
var tasks = panelBottom.addWidget("org.kde.plasma.icontasks");
tasks.currentConfigGroup = ["General"];
tasks.writeConfig("launchers", "applications:org.kde.dolphin.desktop,applications:firefox.desktop,applications:org.kde.konsole.desktop,applications:systemsettings.desktop");
tasks.writeConfig("indicateAudioStreams", "true");
tasks.writeConfig("showOnlyCurrentScreen", "true");
tasks.writeConfig("middleClickAction", "NewInstance");
tasks.writeConfig("wheelEnabled", "true");

// -- Dock Padding Right --
var dockPaddingRight = panelBottom.addWidget("org.kde.plasma.panelspacer");
dockPaddingRight.currentConfigGroup = ["General"];
dockPaddingRight.writeConfig("expanding", "false");
dockPaddingRight.writeConfig("length", "8");


// =========================================================
// 4. ADDITIONAL CONFIGURATIONS
// =========================================================

// --- Splash Screen ---
var ksplashrc = ConfigFile("ksplashrc");
ksplashrc.group = "KSplash";
ksplashrc.writeEntry("Theme", "org.kde.tealight.desktop");
ksplashrc.writeEntry("Engine", "KSplashQML");

// === Dolphin Configuration ===
const IconsStatic_dolphin = ConfigFile('dolphinrc')
IconsStatic_dolphin.group = 'KFileDialog Settings'
IconsStatic_dolphin.writeEntry('Places Icons Static Size', 16)

const PlacesPanel = ConfigFile('dolphinrc')
PlacesPanel.group = 'PlacesPanel'
PlacesPanel.writeEntry('IconSize', 16)

// === Window Decoration Buttons Configuration ===
const Buttons = ConfigFile("kwinrc")
Buttons.group = "org.kde.kdecoration2"
Buttons.writeEntry("ButtonsOnRight", "IAX")
Buttons.writeEntry("ButtonsOnLeft", "")

// === Accent Color Configuration ===
const colorScheme = ConfigFile("kdeglobals")
colorScheme.group = "General"
colorScheme.writeEntry("ColorScheme", "Tea-light")
// colorScheme.writeEntry("AccentColorFromWallpaper", "true")

// === Konsole Profile Configuration ===
const konsoleProfile = ConfigFile("konsolerc")
konsoleProfile.group = "Desktop Entry"
konsoleProfile.writeEntry("DefaultProfile", "Tea-light.profile")

// --- KWin Window Decoration ---
// Define window button layout (Menu on left, Actions on right)
var kwinrc = ConfigFile("kwinrc");
kwinrc.group = "org.kde.kdecoration2";
kwinrc.writeEntry("ButtonsOnLeft", "M");
kwinrc.writeEntry("ButtonsOnRight", "FIAX");
kwinrc.group = "Windows";
kwinrc.writeEntry("BorderlessMaximizedWindows", "true");
