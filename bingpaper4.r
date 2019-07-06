Rebol [
  title: "Bing wallpaper downloader"
  Encap: [title "Bing wallpaper downloader"]
]
#include %source/prot.r
#include %source/view.r

args: any [ system/script/args "" ]
;print rejoin [ "args: " args  "dir: " to-local-file what-dir ]
wallpaper: none
;unless value? 'old_show [ old_show: :show ]

get-wallpaper: func [ /local b h f ][
  not error? try [
    b: http://www.bing.com
    h: parse/all read b {'"&\}
    remove-each s h [ not parse s ["/" thru ".jpg"] ]
    h: first h
    f: to-file find/tail h "." ;filename
    unless exists? to-file f [
      ;download, add missing dpi info for Windows 7
      write/binary f head change skip find read/binary join b h "JFIF" 7 #{0100600060}
    ]
    wallpaper: join what-dir f
  ]
]


set-wallpaper: func [ /local SystemParametersInfo fnam user32-lib ][
  ;SPI_SETDESKWALLPAPER: 20
  ;SPIF_SENDCHANGE: 2
  any [ wallpaper  return false ]
  not error? try [
    SystemParametersInfo: make routine! [
      a[int] b[int] c[string!] d[int] return: [int]
    ] dll: load/library %user32 "SystemParametersInfoA"
    fnam: to-local-file wallpaper
    SystemParametersInfo 20 0 fnam 2
    free dll
    true
   ]
]

all [ find args "-q"  get-wallpaper set-wallpaper ]
all [ find args "-q"  quit ]

comment {{
set-title: func [ t [string!] ][
  user32.dll: load/library %user32.dll
  GetFocus: make routine![return:[int]]user32.dll"GetFocus"
  SetWindowText: make routine![hw[int]a[string!]return:[int]]user32.dll"SetWindowTextA"
  show: func[face][ old_show[face] SetWindowText GetFocus t ]
]
}}

font-arial: make face/font [
  size: 26
  name: "arial black"
  ;style: 'bold ;[bold italic]
]


main: layout/size [


origin 0x0
backdrop effect [gradient 1x1 50.50.50 10.10.20]
img: image make image! [640x400 0.0.0 255]
        rate 1
        feel [engage: func [f a e][
                if a = 'time [
                  f/rate: none show f
                  all [get-wallpaper f/image: load wallpaper updating/effect/draw/6: "Click picture to set wallpaper" show  main]
                ]
                if a = 'down [ set-wallpaper updating/effect/draw/6: "done..." updating/rate: 00:00:03 show main]
                ]
        ]

origin 0x400
updating: box 640x35 black effect [ draw [ pen 200.200.200 font font-arial text "Downloading today's wallpaper..." 80x0 ]]
  feel [engage: func [f a e][ if a = 'time [unview]] ]

] 640x435


;set-title "Bing wallpaper downloader"
;view/options main [no-title]
view main


