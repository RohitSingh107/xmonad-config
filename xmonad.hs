-- Base

-- Actions

-- Data
import           Data.Char                           (isSpace, toUpper)
import qualified Data.Map                            as M
import           Data.Maybe                          (fromJust, isJust)
import           Data.Monoid
import           Data.Tree
import           System.Directory
import           System.Exit                         (exitSuccess)
import           System.IO                           (hPutStrLn)
import           XMonad
import           XMonad.Actions.CopyWindow           (kill1)
import           XMonad.Actions.CycleWS              (Direction1D (..),
                                                      WSType (..), moveTo,
                                                      nextScreen, prevScreen,
                                                      shiftTo)
import           XMonad.Actions.GridSelect
import           XMonad.Actions.MouseResize
import           XMonad.Actions.Promote
import           XMonad.Actions.RotSlaves            (rotAllDown, rotSlavesDown)
import qualified XMonad.Actions.Search               as S
import           XMonad.Actions.WindowGo             (runOrRaise)
import           XMonad.Actions.WithAll              (killAll, sinkAll)
-- Hooks
import           XMonad.Hooks.DynamicLog             (PP (..), dynamicLogWithPP,
                                                      shorten, wrap,
                                                      xmobarColor, xmobarPP)
import           XMonad.Hooks.EwmhDesktops
import           XMonad.Hooks.ManageDocks            (ToggleStruts (..),
                                                      avoidStruts, docks,
                                                      docksEventHook,
                                                      manageDocks)
import           XMonad.Hooks.ManageHelpers          (doCenterFloat,
                                                      doFullFloat, isFullscreen)
import           XMonad.Hooks.ServerMode
import           XMonad.Hooks.SetWMName
import           XMonad.Hooks.StatusBar.PP
import           XMonad.Hooks.WorkspaceHistory
-- Layouts
import           XMonad.Layout.Accordion
import           XMonad.Layout.GridVariants          (Grid (Grid))
-- Layouts modifiers
import           XMonad.Layout.LayoutModifier
import           XMonad.Layout.LimitWindows          (decreaseLimit,
                                                      increaseLimit,
                                                      limitWindows)
import           XMonad.Layout.Magnifier
import qualified XMonad.Layout.MultiToggle           as MT (Toggle (..))
import           XMonad.Layout.MultiToggle           (EOT (EOT), mkToggle,
                                                      single, (??))
import           XMonad.Layout.MultiToggle.Instances (StdTransformers (MIRROR, NBFULL, NOBORDERS))
import           XMonad.Layout.NoBorders
import           XMonad.Layout.Renamed
import           XMonad.Layout.ResizableTile
import           XMonad.Layout.ShowWName
import           XMonad.Layout.Simplest
import           XMonad.Layout.SimplestFloat
import           XMonad.Layout.Spacing
import           XMonad.Layout.Spiral
import           XMonad.Layout.SubLayouts
import           XMonad.Layout.Tabbed
import           XMonad.Layout.ThreeColumns
import qualified XMonad.Layout.ToggleLayouts         as T (ToggleLayout (Toggle),
                                                           toggleLayouts)
import           XMonad.Layout.WindowArranger        (WindowArrangerMsg (..),
                                                      windowArrange)
import           XMonad.Layout.WindowNavigation
import qualified XMonad.StackSet                     as W
-- Utilities
import           XMonad.Util.Dmenu
import           XMonad.Util.EZConfig                (additionalKeysP)
import           XMonad.Util.NamedScratchpad
import           XMonad.Util.Run                     (runProcessWithInput,
                                                      safeSpawn, spawnPipe)
import           XMonad.Util.SpawnOnce

myFont :: String
myFont = "xft:SauceCodePro Nerd Font Mono:regular:size=9:antialias=true:hinting=true"

myModMask :: KeyMask
myModMask = mod4Mask -- Sets modkey to super/windows key

myTerminal :: String
myTerminal = "alacritty" -- Sets default terminal

myBrowser :: String
myBrowser = "qutebrowser" -- Sets qutebrowser as browser

myEmacs :: String
myEmacs = "emacsclient -c -a 'emacs' " -- Makes emacs keybindings easier to type

myEditor :: String
myEditor = "emacsclient -c -a 'emacs' " -- Sets emacs as editor

myBorderWidth :: Dimension
myBorderWidth = 1 -- Sets border width for windows

myNormColor :: String
myNormColor = "#e39ff6" -- Border color of normal windows

myFocusColor :: String
myFocusColor = "#a1045a" -- Border color of focused windows

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

myStartupHook :: X ()
myStartupHook = do
  spawnOnce "lxsession &"
  spawnOnce "picom &"
  -- spawnOnce "nm-applet &"
  -- spawnOnce "volumeicon &"
  -- spawnOnce "conky -c $HOME/.config/conky/doomone-xmonad.conkyrc"
  spawnOnce "trayer --edge top --align right --widthtype request --padding 0 --SetDockType true --SetPartialStrut true --expand false --monitor 0 --transparent true --alpha 60 --tint 0x6790eb  --height 22 &"
  -- spawnOnce "trayer --edge top --align right --widthtype request --padding 0 --SetDockType true --SetPartialStrut false --expand true --monitor 1 --transparent true --alpha 180 --tint 0x282c34  --height 22 &"
  spawnOnce "flameshot &"
  -- spawnOnce "emacs --daemon &" -- emacs daemon for the emacsclient
  -- uncomment to restore last saved wallpaper
  -- spawnOnce "feh --randomize --bg-fill /home/rohit/Pictures/wallpapers/0051.jpg"
  -- spawnOnce "feh --randomize --bg-fill /home/rohit/Pictures/wallpapers/0108.jpg"
  -- spawnOnce "feh --randomize --bg-fill /home/rohit/Pictures/wallpapers/0253.jpg"
  -- spawnOnce "feh --randomize --bg-fill /home/rohits/Pictures/wallpapers/0258.jpg"
  -- spawnOnce "feh --randomize --bg-fill /home/rohit/Pictures/wallpapers/0294.jpg"
  -- spawnOnce "feh --randomize --bg-fill /home/rohit/Pictures/wall.jpg"
  --uncomment to set a random wallpaper on login
  -- spawnOnce "find /usr/share/backgrounds/dtos-backgrounds/ -type f | shuf -n 1 | xargs xwallpaper --stretch"

  -- spawnOnce "~/.fehbg &"  -- set last saved feh wallpaper
  spawnOnce "feh --randomize --bg-fill ~/Pictures/wallpapers/" -- feh set random wallpaper
  -- spawnOnce "nitrogen --restore &"   -- if you prefer nitrogen to feh
  setWMName "LG3D"

myColorizer :: Window -> Bool -> X (String, String)
myColorizer =
  colorRangeFromClassName
    (0x28, 0x2c, 0x34) -- lowest inactive bg
    (0x28, 0x2c, 0x34) -- highest inactive bg
    (0xc7, 0x92, 0xea) -- active bg
    (0xc0, 0xa7, 0x9a) -- inactive fg
    (0x28, 0x2c, 0x34) -- active fg

-- gridSelect menu layout
mygridConfig :: p -> GSConfig Window
mygridConfig colorizer =
  (buildDefaultGSConfig myColorizer)
    { gs_cellheight = 40,
      gs_cellwidth = 200,
      gs_cellpadding = 6,
      gs_originFractX = 0.5,
      gs_originFractY = 0.5,
      gs_font = myFont
    }

spawnSelected' :: [(String, String)] -> X ()
spawnSelected' lst = gridselect conf lst >>= flip whenJust spawn
  where
    conf =
      def
        { gs_cellheight = 40,
          gs_cellwidth = 200,
          gs_cellpadding = 6,
          gs_originFractX = 0.5,
          gs_originFractY = 0.5,
          gs_font = myFont
        }

myAppGrid =
  [ ("Termonad", "termonad"),
    ("PCManFM", "pcmanfm"),
    ("Emacs", "emacsclient -c -a emacs"),
    ("iPython", "alacritty -e ipython"),
    ("FreeTube", "freetube"),
    ("Kolourpaint", "kolourpaint"),
    ("Sublime Text", "subl"),
    ("Codium", "codium"),
    ("Haskell Book", "okular ~/Documents/haskell-programming-first-principles.pdf"),
    ("Geany", "geany"),
    ("LibreOffice", "libreoffice"),
    ("Stacer", "stacer"),
    ("Alacritty", "alacritty")
  ]

myWebGrid =
  [ ("Qutebrowser", "qutebrowser"),
    ("Brave", "brave"),
    ("Firefox", "firefox"),
    ("Brave Nightly", "brave-nightly"),
    ("Freetube", "freetube"),
    ("Teams", "teams"),
    ("Firefox Nightly", "firefox-nightly"),
    ("Vivaldi", "vivaldi-stable"),
    ("Kotatogram", "kotatogram-desktop"),
    ("Discord", "discord"),
    ("Google Chrome (Don't use it)", "google-chrome-unstable"),
    ("Chromium", "chromium")
    -- , ("GeaXXny", "geany")
  ]

myScratchPads :: [NamedScratchpad]
myScratchPads =
  [ NS "terminal" spawnTerm findTerm manageTerm,
    NS "mocp" spawnMocp findMocp manageMocp,
    NS "calculator" spawnCalc findCalc manageCalc,
    NS "browser" spawnBrowser findBrowser manageBrowser
  ]
  where
    spawnTerm = myTerminal ++ " -t scratchpad"
    -- spawnTerm  = myTerminal ++ " -e bash"
    findTerm = title =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
      where
        h = 0.9
        w = 0.9
        t = 0.95 - h
        l = 0.95 - w

    spawnBrowser = "firefox"
    findBrowser = className =? "firefox"
    manageBrowser = customFloating $ W.RationalRect l t w h
      where
        h = 0.9
        w = 0.9
        t = 0.95 - h
        l = 0.95 - w

    spawnMocp = myTerminal ++ " -t mocp -e mocp"
    findMocp = title =? "mocp"
    manageMocp = customFloating $ W.RationalRect l t w h
      where
        h = 0.9
        w = 0.9
        t = 0.95 - h
        l = 0.95 - w
    spawnCalc = "qalculate-gtk"
    findCalc = className =? "Qalculate-gtk"
    manageCalc = customFloating $ W.RationalRect l t w h
      where
        h = 0.5
        w = 0.4
        t = 0.75 - h
        l = 0.70 - w

--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Defining a bunch of layouts, many that I don't use.
-- limitWindows n sets maximum number of windows displayed for layout.
-- mySpacing n sets the gap size around the windows.
tall =
  renamed [Replace "tall"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          subLayout [] (smartBorders Simplest) $
            limitWindows 6 $
              mySpacing 4 $
                ResizableTall 1 (3 / 100) (1 / 2) []

magnify =
  renamed [Replace "magnify"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          subLayout [] (smartBorders Simplest) $
            magnifier $
              limitWindows 12 $
                mySpacing 8 $
                  ResizableTall 1 (3 / 100) (1 / 2) []

monocle =
  renamed [Replace "monocle"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          subLayout [] (smartBorders Simplest) $
            limitWindows 20 Full

floats =
  renamed [Replace "floats"] $
    smartBorders $
      limitWindows 20 simplestFloat

grid =
  renamed [Replace "grid"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          subLayout [] (smartBorders Simplest) $
            limitWindows 12 $
              mySpacing 8 $
                mkToggle (single MIRROR) $
                  Grid (16 / 10)

spirals =
  renamed [Replace "spirals"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          subLayout [] (smartBorders Simplest) $
            mySpacing' 8 $
              spiral (6 / 7)

threeCol =
  renamed [Replace "threeCol"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          subLayout [] (smartBorders Simplest) $
            limitWindows 7 $
              ThreeCol 1 (3 / 100) (1 / 2)

threeRow =
  renamed [Replace "threeRow"] $
    smartBorders $
      windowNavigation $
        addTabs shrinkText myTabTheme $
          subLayout [] (smartBorders Simplest) $
            limitWindows 7
            -- Mirror takes a layout and rotates it by 90 degrees.
            -- So we are applying Mirror to the ThreeCol layout.
            $
              Mirror $
                ThreeCol 1 (3 / 100) (1 / 2)

tabs =
  renamed [Replace "tabs"]
  -- I cannot add spacing to this layout because it will
  -- add spacing between window and tabs which looks bad.
  $
    tabbed shrinkText myTabTheme

tallAccordion =
  renamed [Replace "tallAccordion"] $
    Accordion

wideAccordion =
  renamed [Replace "wideAccordion"] $
    Mirror Accordion

-- setting colors for tabs layout and tabs sublayout.
myTabTheme =
  def
    { fontName = myFont,
      activeColor = "#46d9ff",
      inactiveColor = "#313846",
      activeBorderColor = "#46d9ff",
      inactiveBorderColor = "#282c34",
      activeTextColor = "#282c34",
      inactiveTextColor = "#d0d0d0"
    }

-- Theme for showWName which prints current n when you change workspaces.
myShowWNameTheme :: SWNConfig
myShowWNameTheme =
  def
    { swn_font = "xft:Ubuntu:bold:size=60",
      swn_fade = 1.0,
      swn_bgcolor = "#1c1f24",
      swn_color = "#ffffff"
    }

-- The layout hook
myLayoutHook =
  avoidStruts $
    mouseResize $
      windowArrange $
        T.toggleLayouts floats $
          mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
  where
    myDefaultLayout =
      withBorder myBorderWidth tall
        ||| Main.magnify
        ||| noBorders monocle
        ||| floats
        ||| noBorders tabs
        ||| grid
        ||| spirals
        ||| threeCol
        ||| threeRow
        ||| tallAccordion
        ||| wideAccordion

myWorkspaces = ["α ", "β ", "γ ", "δ ", "ε ", "ζ ", "η ", "θ ", "ι "]

-- myWorkspaces = [" dev ", " www ", " sys ", " doc ", " vbox ", " chat ", " mus ", " vid ", " gfx "]
myWorkspaceIndices = M.fromList $ zip myWorkspaces [1 ..] -- (,) == \x y -> (x,y)

clickable ws = "<action=xdotool key super+" ++ show i ++ ">" ++ ws ++ "</action>"
  where
    i = fromJust $ M.lookup ws myWorkspaceIndices

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook =
  composeAll
    -- 'doFloat' forces a window to float.  Useful for dialog boxes and such.
    -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
    -- I'm doing it this way because otherwise I would have to write out the full
    -- name of my workspaces and the names would be very long if using clickable workspaces.
    [ className =? "confirm" --> doFloat,
      className =? "file_progress" --> doFloat,
      className =? "dialog" --> doFloat,
      className =? "download" --> doFloat,
      className =? "error" --> doFloat,
      className =? "Gimp" --> doFloat,
      className =? "notification" --> doFloat,
      className =? "pinentry-gtk-2" --> doFloat,
      className =? "splash" --> doFloat,
      className =? "toolbar" --> doFloat,
      className =? "Nwggrid-server" --> doFloat,
      className =? "nwggrid" --> doFloat,
      className =? "Yad" --> doCenterFloat,
      className =? "Open Folder" --> doCenterFloat,
      title =? "Oracle VM VirtualBox Manager" --> doFloat,
      -- , title =? "Mozilla Firefox"     --> doShift ( myWorkspaces !! 3 )
      -- , className =? "brave-browser"   --> doShift ( myWorkspaces !! 1 )
      -- , className =? "qutebrowser"     --> doShift ( myWorkspaces !! 1 )
      className =? "mpv" --> doShift (myWorkspaces !! 7),
      className =? "Gimp" --> doShift (myWorkspaces !! 8),
      -- , className =? "VirtualBox Manager" --> doShift  ( myWorkspaces !! 4 )
      (className =? "firefox" <&&> resource =? "Dialog") --> doFloat, -- Float Firefox Dialog
      isFullscreen --> doFullFloat
    ]
    <+> namedScratchpadManageHook myScratchPads

-- START_KEYS
myKeys :: [(String, X ())]
myKeys =
  -- SUPER + SHIFT KEYS
  [ ("M-S-r", spawn "xmonad --restart"), -- Recompiles xmonad
    ("M-S-x", io exitSuccess), -- Quits xmonad
    ("M-S-/", spawn "~/.config/xmonad/xmonad_keys.sh"),
    ("M-S-<Return>", spawn "pcmanfm"), -- PCManFM
    -- , ("M-S-<Return>", spawn "dmenu_run -i -p \"Run: \"") -- Dmenu
    ("M-S-d", spawn "dmenu_run -i -nb '#191919' -nf '#ff1493' -sb '#ff1493' -sf '#191919' -fn 'NotoMonoRegular:bold:pixelsize=15' -p \"Run: \""), -- Dmenu
    ("M-S-q", kill1), -- Kill the currently focused client
    ("M-S-a", killAll), -- Kill all windows on current workspace

    -- SUPER + ... KEYS
    ("M-<Return>", spawn (myTerminal)),
    ("M-b", spawn (myBrowser)),
    ("M-d", spawn ("nwggrid -p -o 0.4")),
    -- SUPER + s KEYSTROKES
    ("C-<Return>", namedScratchpadAction myScratchPads "terminal"),
    ("C-w", namedScratchpadAction myScratchPads "browser"),
    ("M-s m", namedScratchpadAction myScratchPads "mocp"),
    ("M-s c", namedScratchpadAction myScratchPads "calculator"),
    -- SUPER + ALT KEYS
    ("M-M1-h", spawn (myTerminal ++ " -e htop")),
    -- CONTROL + ... KEYS
    ("C-g g", spawnSelected' myAppGrid), -- grid select favorite apps
    ("C-g w", spawnSelected' myWebGrid), -- grid select favorite apps
    ("C-g t", goToSelected $ mygridConfig myColorizer), -- goto selected window
    ("C-g b", bringSelected $ mygridConfig myColorizer), -- bring selected window

    -- CONTROL + ALT KEYS
    ("C-M1-p", spawn ("$HOME/.config/xmonad/picom-toggle.sh")),
    ("C-M1-w", spawn ("feh --randomize --bg-fill /home/rohits/Pictures/wallpapers/*.jpg")),
    -- CONTROL + e KEYSTROKES
    -- , ("C-e e", spawn myEmacs)                 -- start emacs
    ("C-e e", spawn (myEmacs ++ ("--eval '(dashboard-refresh-buffer)'"))), -- emacs dashboard
    ("C-e b", spawn (myEmacs ++ ("--eval '(ibuffer)'"))), -- list buffers
    ("C-e d", spawn (myEmacs ++ ("--eval '(dired nil)'"))), -- dired
    ("C-e i", spawn (myEmacs ++ ("--eval '(erc)'"))), -- erc irc client
    ("C-e s", spawn (myEmacs ++ ("--eval '(eshell)'"))), -- eshell
    ("C-e t", spawn (myEmacs ++ ("--eval '(mastodon)'"))), -- mastodon.el
    ("C-e v", spawn (myEmacs ++ ("--eval '(vterm nil)'"))), -- vterm if on GNU Emacs
    ("C-e w", spawn (myEmacs ++ ("--eval '(eww \"distrotube.com\")'"))), -- eww browser if on GNU Emacs

    -- Super + p KEYSTROKES (dmenu)
    ("M-p a", spawn "dm-sounds"), -- choose an ambient background
    ("M-p b", spawn "dm-setbg"), -- set a background
    ("M-p c", spawn "dm-colpick"), -- pick color from our scheme
    ("M-p e", spawn "dm-confedit"), -- edit config files
    ("M-p i", spawn "dm-maim"), -- screenshots (images)
    ("M-p k", spawn "dm-kill"), -- kill processes
    ("M-p m", spawn "dm-man"), -- manpages
    ("M-p o", spawn "dm-bookman"), -- qutebrowser bookmarks/history
    ("M-p p", spawn "passmenu"), -- passmenu
    ("M-p q", spawn "dm-logout"), -- logout menu
    ("M-p r", spawn "dm-reddit"), -- reddio (a reddit viewer)
    ("M-p s", spawn "dm-websearch"), -- search various search engines

    -- SUPER + FUNCTION KEYS
    ("M-<F1>", spawn "sxiv -r -q -t -o /usr/share/backgrounds/dtos-backgrounds/*"),
    ("M-<F2>", spawn "find /usr/share/backgrounds/dtos-backgrounds// -type f | shuf -n 1 | xargs xwallpaper --stretch"),
    -- SCREENSHOT
    ("C-<Print>", spawn "flameshot"),
    ("<Print>", spawn "flameshot full -p $HOME/Pictures"),
    -- Windows Movement and Focus Shift

    -- Move Window to Workspace
    ("M-.", nextScreen), -- Switch focus to next monitor
    ("M-,", prevScreen), -- Switch focus to prev monitor
    ("M-S-<KP_Add>", shiftTo Next nonNSP >> moveTo Next nonNSP), -- Shifts focused window to next ws
    ("M-S-<KP_Subtract>", shiftTo Prev nonNSP >> moveTo Prev nonNSP), -- Shifts focused window to prev ws

    -- Shift Focus
    ("M-m", windows W.focusMaster), -- Move focus to the master window
    ("M-j", windows W.focusDown), -- Move focus to the next window
    ("M-<Down>", windows W.focusDown), -- Move focus to the next window
    ("M-k", windows W.focusUp), -- Move focus to the prev window
    ("M-<Up>", windows W.focusUp), -- Move focus to the prev window

    -- Swapping and Movement
    ("M-S-m", windows W.swapMaster), -- Swap the focused window and the master window
    ("M-S-j", windows W.swapDown), -- Swap focused window with next window
    ("M-S-k", windows W.swapUp), -- Swap focused window with prev window
    ("M-<Backspace>", promote), -- Moves focused window to master, others maintain order
    ("M-S-<Tab>", rotSlavesDown), -- Rotate all windows except master and keep focus in place
    ("M-C-<Tab>", rotAllDown), -- Rotate all the windows in the current stack

    -- Increasing/Decreasing Windows Spacing (Gaps) and Size

    -- Increase/decrease spacing (gaps)
    ("C-M1-j", decWindowSpacing 4), -- Decrease window spacing
    ("C-M1-k", incWindowSpacing 4), -- Increase window spacing
    ("C-M1-h", decScreenSpacing 4), -- Decrease screen spacing
    ("C-M1-l", incScreenSpacing 4), -- Increase screen spacing

    -- Toggle Float/Tiling
    ("M-f", sendMessage (T.Toggle "floats")), -- Toggles my 'floats' layout
    ("M-t", withFocused $ windows . W.sink), -- Push floating window back to tile
    ("M-S-t", sinkAll), -- Push ALL floating windows to tile

    -- Switch Layouts and Toggle FULLSCREEN
    ("M-<Tab>", sendMessage NextLayout), -- Switch to next layout
    ("M-<Space>", sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts), -- Toggles noborder/full

    -- KB_GROUP Increase/decrease windows in the master pane or the stack
    ("M-M1-k", sendMessage (IncMasterN 1)), -- Increase # of clients master pane
    ("M-M1-j", sendMessage (IncMasterN (-1))), -- Decrease # of clients master pane
    ("M-C-<Up>", increaseLimit), -- Increase # of windows
    ("M-C-<Down>", decreaseLimit), -- Decrease # of windows

    -- KB_GROUP Window resizing
    ("M-h", sendMessage Shrink), -- Shrink horiz window width
    ("M-l", sendMessage Expand), -- Expand horiz window width
    ("M-S-<Down>", sendMessage MirrorShrink), -- Shrink vert window width
    ("M-S-<Up>", sendMessage MirrorExpand), -- Expand vert window width

    -- KB_GROUP Sublayouts
    -- This is used to push windows to tabbed sublayouts, or pull them out of it.
    ("M-C-h", sendMessage $ pullGroup L),
    ("M-C-l", sendMessage $ pullGroup R),
    ("M-C-k", sendMessage $ pullGroup U),
    ("M-C-j", sendMessage $ pullGroup D),
    ("M-C-m", withFocused (sendMessage . MergeAll)),
    -- , ("M-C-u", withFocused (sendMessage . UnMerge))
    ("M-C-/", withFocused (sendMessage . UnMergeAll)),
    ("M-C-.", onGroup W.focusUp'), -- Switch focus to next tab
    ("M-C-,", onGroup W.focusDown'), -- Switch focus to prev tab

    -- Brightness Control

    ("<XF86MonBrightnessUp>", spawn "brightnessctl s +5%"),
    ("<XF86MonBrightnessDown>", spawn "brightnessctl s 5%-"),
    -- KB_GROUP Multimedia Keys
    ("<XF86AudioPlay>", spawn "mocp --play"),
    ("<XF86AudioPrev>", spawn "mocp --previous"),
    ("<XF86AudioNext>", spawn "mocp --next"),
    ("<XF86AudioMute>", spawn "amixer set Master toggle"),
    ("<XF86AudioLowerVolume>", spawn "amixer set Master 5%- unmute"),
    ("<XF86AudioRaiseVolume>", spawn "amixer set Master 5%+ unmute"),
    ("<XF86Search>", spawn "dm-websearch"),
    ("<XF86Mail>", runOrRaise "thunderbird" (resource =? "thunderbird")),
    ("<XF86Calculator>", runOrRaise "qalculate-gtk" (resource =? "qalculate-gtk")),
    ("<XF86Eject>", spawn "toggleeject")
  ]
  where
    -- The following lines are needed for named scratchpads.
    nonNSP = WSIs (return (\ws -> W.tag ws /= "NSP"))
    nonEmptyNonNSP = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "NSP"))

-- END_KEYS

main :: IO ()
main = do
  -- Launching three instances of xmobar on their monitors.
  xmproc0 <- spawnPipe "~/.local/bin/xmobar"
  -- xmproc1 <- spawnPipe "xmobar -x 1 $HOME/.config/xmobar/xmobarrc"
  -- xmproc2 <- spawnPipe "xmobar -x 2 $HOME/.config/xmobar/xmobarrc"
  -- the xmonad, ya know...what the WM is named after!
  xmonad $
    ewmh
      $docks
      def
        { manageHook = myManageHook <+> manageDocks,
          --        , handleEventHook    = docks
          -- Uncomment this line to enable fullscreen support on things like YouTube/Netflix.
          -- This works perfect on SINGLE monitor systems. On multi-monitor systems,
          -- it adds a border around the window if screen does not have focus. So, my solution
          -- is to use a keybinding to toggle fullscreen noborders instead.  (M-<Space>)
          -- <+> fullscreenEventHook
          modMask = myModMask,
          terminal = myTerminal,
          startupHook = myStartupHook,
          -- , layoutHook         = showWName' myShowWNameTheme $ myLayoutHook
          layoutHook = myLayoutHook,
          workspaces = myWorkspaces,
          borderWidth = myBorderWidth,
          normalBorderColor = myNormColor,
          focusedBorderColor = myFocusColor,
          --        , logHook = dynamicLogWithPP $ namedScratchpadFilterOutWorkspacePP $ xmobarPP
          logHook =
            dynamicLogWithPP $
              XMonad.Hooks.StatusBar.PP.filterOutWsPP [scratchpadWorkspaceTag] $
                xmobarPP
                  { -- the following variables beginning with 'pp' are settings for xmobar.
                    ppOutput = \x -> hPutStrLn xmproc0 x, -- xmobar on monitor 1
                    --  >> hPutStrLn xmproc1 x                          -- xmobar on monitor 2
                    --  >> hPutStrLn xmproc2 x                          -- xmobar on monitor 3


--                     ppCurrent = xmobarColor "#c792ea" "" . wrap "[ " "]", -- Current workspace
--                     ppVisible = xmobarColor "#c792ea" "" . clickable, -- Visible but not current workspace
--                     ppHidden = xmobarColor "#ff5050" "" . clickable, -- Hidden workspaces
--                     ppHiddenNoWindows = xmobarColor "#98c379" "" . clickable, -- Hidden workspaces (no windows)
--                     ppTitle = xmobarColor "#b3afc2" "" . shorten 48, -- Title of active window
--                     ppSep = "<fc=#666666> <fn=1>|</fn> </fc>", -- Separator character


                    ppCurrent = xmobarColor "#ffff00" "" . wrap "[ " "]", -- Current workspace
                    ppVisible = xmobarColor "#ffffff" "" . clickable, -- Visible but not current workspace
                    ppHidden = xmobarColor "#ffff00" "" . clickable, -- Hidden workspaces
                    ppHiddenNoWindows = xmobarColor "#0000ff" "" . clickable, -- Hidden workspaces (no windows)
                    ppTitle = xmobarColor "#ffff00" "" . shorten 48, -- Title of active window
                    ppSep = "<fc=#000000> <fn=1>|</fn> </fc>", -- Separator character
                    ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!", -- Urgent workspace
                    ppExtras = [windowCount], -- # of windows current workspace
                    ppOrder = \(ws : l : t : ex) -> [ws, l] ++ ex ++ [t] -- order of things in xmobar
                  }
        }
      `additionalKeysP` myKeys
