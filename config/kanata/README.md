# KANATA

#### Keyboard modifictions could be done, specifically macro to shorten the type counts and enhance the productivity. Following is an example.

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

- [ ] macro for tmux
- [ ] macro for git