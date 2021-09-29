Config { 

--open Eq.≡-Reasoning using (begin_; _≡⟨⟩_; _∎)
--data ℕ : Set where
 
   -- appearance
     font =         "xft:Terminus:size=10:bold:antialias=true"
   , bgColor =      "#black"
   , fgColor =      "#white"
   , position =     Top
   , border =       BottomB
   , borderColor =  "#white"
   , borderWidth =  1

   -- layout
   , sepChar =  "%"   -- delineator between plugin names and straight text
   , alignSep = "}{"  -- separator between left-right alignment
   , template = "%StdinReader% │ %battery% %multicpu% %coretemp% %memory% %dynnetwork% }{ %RJTT% │ %date%"

   -- general behavior
   , lowerOnStart =     True    -- send to bottom of window stack on start
   , hideOnStart =      False   -- start with window unmapped (hidden)
   , allDesktops =      True    -- show on all desktops
   , overrideRedirect = True    -- set the Override Redirect flag (Xlib)
   , pickBroadest =     False   -- choose widest display (multi-monitor)
   , persistent =       True    -- enable/disable hiding (True = disabled)

   -- plugins
   --   Numbers can be automatically colored according to their value. xmobar
   --   decides color based on a three-tier/two-cutoff system, controlled by
   --   command options:
   --     --Low sets the low cutoff
   --     --High sets the high cutoff
   --
   --     --low sets the color below --Low cutoff
   --     --normal sets the color between --Low and --High cutoffs
   --     --High sets the color above --High cutoff
   --
   --   The --template option controls how the plugin is displayed. Text
   --   color can be set by enclosing in <fc></fc> tags. For more details
   --   see http://projects.haskell.org/xmobar/#system-monitor-plugins.
   , commands = 

        -- weather monitor
        [ Run Weather "RJTT" [ "--template", "<fc=#blue><skyCondition></fc> │ <fc=#blue><tempC></fc>°C"
                             ] 36000

        -- network activity monitor (dynamic interface resolution)
        -- , Run DynNetwork     [ "--template" , "<dev> : <tx>kB/s|<rx>kB/s"
        , Run DynNetwork     [ "--template" , "<tx>kB/s│<rx>kB/s"
                             , "--Low"      , "1000"       -- units: B/s
                             , "--High"     , "5000"       -- units: B/s
                             , "--low"      , "#green"
                             , "--normal"   , "#yelllow"
                             , "--high"     , "#red"
                             ] 10

        -- cpu activity monitor
        , Run MultiCpu       [ "--template" , "<total0>%"
                             , "--Low"      , "50"         -- units: %
                             , "--High"     , "85"         -- units: %
                             , "--low"      , "#green"
                             , "--normal"   , "#yelllow"
                             , "--high"     , "#red"
                             ] 10

        -- cpu core temperature monitor
        , Run CoreTemp       [ "--template" , "<core0>°C"
                             , "--Low"      , "70"        -- units: °C
                             , "--High"     , "80"        -- units: °C
                             , "--low"      , "#green"
                             , "--normal"   , "#yelllow"
                             , "--high"     , "#red"
                             ] 50
                          
        -- memory usage monitor
        , Run Memory         [ "--template" , "<usedratio>%"
                             , "--Low"      , "20"        -- units: %
                             , "--High"     , "90"        -- units: %
                             , "--low"      , "#green"
                             , "--normal"   , "#yellow"
                             , "--high"     , "#red"
                             ] 10

        -- battery monitor
        , Run Battery        [ "--template" , "<acstatus>"
                             , "--Low"      , "10"        -- units: %
                             , "--High"     , "80"        -- units: %
                             , "--low"      , "#red"
                             , "--normal"   , "#yellow"
                             , "--high"     , "#green"

                             , "--" -- battery specific options
                                       -- discharging status
                                       , "-o"	, "<left>% (<timeleft>)"
                                       -- AC "on" status
                                       , "-O"	, "<fc=#yellow>Charging</fc>"
                                       -- charged status
                                       , "-i"	, "<fc=#green>Charged</fc>"
                             ] 50

        -- time and date indicator 
        --   (%F = y-m-d date, %a = day of week, %T = h:m:s time)
        --, Run Date           "<fc=#cyan>%F</fc> \<%a\> <fc=#cyan>%T</fc>" "date" 10
        , Run Date           "<fc=#green>%F</fc> ⟨%a⟩ <fc=#green>%T</fc>" "date" 10

        -- keyboard layout indicator
        , Run Kbd            [ ("us(dvorak)" , "<fc=#blue>DV</fc>")
                             , ("us"         , "<fc=#blue>US</fc>")
                             ]
	, Run StdinReader
        ]
   }
