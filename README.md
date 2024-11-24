# dotfiles

### Todo List

- [ ] z-shell, starship and configuration
- [ ] install fonts with all nerds and languages
- [ ] themeing everforest
- [ ] kitty configuration
- [ ] waybar, rofi and dunst / swaync configuration
- [ ] hyprland, hypridle, hyprlock and hyprpaper configurtion
- [ ] neovim setup and configuration
- [ ] install remaining libs and applications
- [ ] kanata setup and configuration
- [ ] logitech mx master 2s configuration
- [ ] dev tools node, bun, deno, postgres, mongodb installation
- [ ] all mime-type setup with default applications
- [ ] yazi full configurtion with thunar or pcmanfm (incluing archieve roller)
- [ ] keystroke printer on screen
- [ ] web playback idle inhibitor


### Need modification upgradation. There are errors with the symbols, by which the layers

```lisp
(defcfg
  linux-dev {{ . }}
)

(defsrc
  esc  1    2    3    4    5    6    7    8    9    0    -    =    bspc ins
  tab  q    w    e    r    t    y    u    i    o    p    [    ]    \    del
  caps a    s    d    f    g    h    j    k    l    ;    '    ret
  lsft z    x    c    v    b    n    m    ,    .    /    rsft up
  lctl lmet lalt           spc            ralt rctl rmet left down rght
)

(deflayer dvorak
  @esc 1    2    3    4    5    6    7    8    9    0    [    ]    bspc ins
  tab  '    ,    .    p    y    f    g    c    r    l    /    =    \    del
  @cap @tmu o    e    @arr i    d    h    t    n    s    -    ret
  lsft ;    q    j    k    x    b    m    w    v    z    rsft up
  lctl lmet lalt           spc            ralt rctl rmet left down rght
)

(deflayer qwerty
  @esc 1    2    3    4    5    6    7    8    9    0    -    =    bspc ins
  tab  q    w    e    r    t    y    u    i    o    p    [    ]    \    del
  caps a    s    d    f    g    h    j    k    l    ;    '    ret
  lsft z    x    c    v    b    n    m    ,    .    /    rsft up
  lctl lmet lalt           spc            ralt rctl rmet left down rght
)

(defalias
  esc (tap-hold 200 200 esc (layer-toggle layers))
  tmu (tap-hold 200 200 a (layer-toggle tmux))
  arr (tap-hold 200 200 u (layer-toggle arrows))
  tl (macro C-b h)
  tr (macro C-b l)
  tj (macro C-b j)
  tk (macro C-b k)
  ts (macro C-b S-\)
  tv (macro C-b -)
  tn (macro C-b ,)
  tc (macro C-b c)
  tf (macro C-b n)
  tp (macro C-b p)
  tmc (macro C-b [)
  tmp (macro C-b ])
  ;; layer-switch changes the base layer.
  dvk (layer-switch dvorak)
  qwr (layer-switch qwerty)

  ;; tap for capslk, hold for lctl
  cap (tap-hold 200 200 caps lctl)
)

;; The keys 1 and 2 switch the base layer to qwerty and dvorak respectively.
(deflayer layers
  _    @qwr @dvk _    _    _    _    _    _    _    _    _    _    _ _
  _    _    _    _    _    _    _    _    _    _    _    _    _    _ _
  _    _    _    _    _    _    _    _    _    _    _    _    _
  _    _    _    _    _    _    _    _    _    _    _    _    _
  _    _    _              _              _    _    _    _    _    _
)

;; Layer for easy tmux usage.
(deflayer tmux
  _    @qwr @dvk _    _    _    _    _    _    _    _    _    _   _ _
  _    _    _    _    _    _    _   @tc  @ts  @tv  @tn   _    _   _ _
  _    _    @tmc @tmp _    @tf  @tp @tl  @tj  @tk  @tr   _    _
  _    _    _    _    _    _    _    _    _    _    _    _    _
  _    _    _              _              _    _    _    _    _   _
)

;; Layer for using vim movement keys everywhere.
(deflayer arrows
  _    f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12 _ _
  _    _    _    _    _    _    _    pgup up   pgdn _    _    _   _ _
  _    _    _    _    _    _    home left down rght end  _    _
  _    _    _    _    _    _    _    _    _    _    _    _    _
  _    _    _              _              _    _    _    _    _   _
)
```


##### code that is in use

```lisp
(defcfg
  process-unmapped-keys yes
)

(defsrc
  grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
  caps a    s    d    f    g    h    j    k    l    ;    '    ret
  lsft z    x    c    v    b    n    m    ,    .    /    rsft
  lctl lmet lalt           spc            ralt rmet rctl
)

(deflayer default
  grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
  caps @a   @s   @d   @f   g    h    @j   @k   @l   @scln '    ret
  esc  z    x    c    v    b    n    m    ,    .    /    bspc
  @nav lmet lalt          spc            @num rmet rctl
)

(deflayer numbers
  _    _    _    _    _    _    _    _    _    _    _    _    _    _
  _   kp7  kp8  kp9   _    _    _    _    _    _    _    _    _    _
  _   kp4  kp5  kp6  kp0   _    _   kp/  kp*  kp+  kp-   _    _
  _   kp1  kp2  kp3   _    _    _    _    _    _    _    _
  _    _    _              spc              _    _    _
)

(deflayer navigation
  _    _    _    _    _    _    _    _    _    _    _    _    _    _
  _    _    _    _    _    _    _    _    _    _    _    _    _    _
  _   lmet lalt lsft lctl  _   left down up  right home    _    _
  _    _    _    _    _    _    _    _    _    _    _    _
  _    _    _              spc              _    _    _
)

(defalias
  
  ;; Left hand homerow mods
  a    (tap-hold 250 300 a lmet)   ;; a + left cmd/windows
  s    (tap-hold 250 300 s lalt)   ;; s + left alt
  d    (tap-hold 250 300 d lsft)   ;; d + left shift
  f    (tap-hold 250 300 f lctl)   ;; f + left control

  ;; Right hand homerow mods
  j    (tap-hold 250 300 j rctl)   ;; j + right control
  k    (tap-hold 250 300 k rsft)   ;; k + right shift
  l    (tap-hold 250 300 l ralt)   ;; l + right alt
  scln (tap-hold 250 300 ; rmet)   ;; ; + right cmd/windows

  ;; Layer toggle aliases
  num  (layer-toggle numbers)  ;; Right Alt now toggles number layer
  nav  (layer-toggle navigation) ;; Left CTRL now toggles arrow layer
)
```