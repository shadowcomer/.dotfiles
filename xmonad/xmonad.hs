import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.EwmhDesktops
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing
import System.IO

import Control.Monad
import Data.Maybe
import Data.List

myWorkspaces = ["1", "2", "3", "4:Communications", "5", "6", "7", "8", "9"]

setFullscreenSupported :: X ()
setFullscreenSupported = addSupported ["_NET_WM_STATE", "_NET_WM_STATE_FULLSCREEN"]

addSupported :: [String] -> X ()
addSupported props = withDisplay $ \dpy -> do
    r <- asks theRoot
    a <- getAtom "_NET_SUPPORTED"
    newSupportedList <- mapM (fmap fromIntegral . getAtom) props
    io $ do
      supportedList <- fmap (join . maybeToList) $ getWindowProperty32 dpy a r
      changeProperty32 dpy r a aTOM propModeReplace (nub $ newSupportedList ++ supportedList)

myModMask = mod4Mask

myManageHook = composeAll [
    manageDocks,
    isFullscreen --> doFullFloat,
    manageHook def
    ]

myHandleEventHook = fullscreenEventHook

keymap = [
    ((myModMask .|. shiftMask, xK_l), spawn "xscreensaver-command -lock")
    ,((myModMask, xK_backslash), spawn "slock")
    ]

main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ ewmh $ docks def
        { startupHook = setFullscreenSupported
        , layoutHook = smartBorders . avoidStruts $ layoutHook def
        , logHook = dynamicLogWithPP xmobarPP
            { ppOutput = hPutStrLn xmproc
            , ppTitle = xmobarColor "green" "" . shorten 50
            }
        , manageHook = myManageHook
        , handleEventHook = myHandleEventHook
        , workspaces = myWorkspaces
        , modMask = myModMask
        , terminal = "rxvt-unicode"
        } `additionalKeys` keymap
