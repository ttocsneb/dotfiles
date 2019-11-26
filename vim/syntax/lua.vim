" Vim syntax file
" Language: Lua
" Maintainer: Benjamin Jacobs
" Latest Revision: 14 Nov 2019

if exists("b:current_syntax")
        finish
endif

" Basic Keywords

syn keyword bool true false
syn keyword const nil
syn keyword store local

"syn match operator '[+-\*/]'
syn keyword operator and or not
syn keyword cond if else elseif end
syn keyword rep for do while in until repeat break
syn keyword basicLanguageKeywords function return 

" Computercraft API
syn keyword api bit colors commands coroutine disk fs gps help http io keys math multishell os paintutils parallel peripheral rednet redstone settings shell string table term textutils turtle vector window

" Numbers

syn match number '\d\+'
syn match number '\d\+.\d*'

syn match number '[-+]\d\+'
syn match number '[-+]\d\+.\d*'


" String
syn match string '".\{-}\(\\\)\@<!"'
syn match string "'.\{-}\(\\\)\@<!'"

" Folds
syn region thenBlock start="then" end="end" fold transparent
syn region doBlock start="do" end="end" fold transparent
syn region funcBlock start="function.\{-})" end="end" fold transparent 

" Comments
syn keyword todo contained TODO NOTE
syn match comment "--.*$" contains=todo

" Syntax Highlighting

let b:current_syntax = "lua"

hi def link cond Conditional
hi def link rep Repeat
hi def link operator Operator
hi def link const Constant
hi def link store StorageClass
hi def link thenBlock Statement
hi def link doBlock Statement
hi def link funcBlock Statement
hi def link bool Boolean
hi def link number Number
hi def link string String
hi def link comment Comment
hi def link api Type
hi def link todo Todo
