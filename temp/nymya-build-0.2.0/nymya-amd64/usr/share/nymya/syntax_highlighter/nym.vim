" Vim syntax file for NymyaLang (.nym)
" Language: NymyaLang
" Maintainer: Erick
" Last Change: 2025-12-06

if exists("b:current_syntax")
  finish
endif

" Keywords
syn keyword nymKeyword import func init class struct namespace var val static export extern macro
syn keyword nymKeyword if else elif while for range return break continue this
syn keyword nymKeyword true false

" Types
syn keyword nymType Void Any Int Float String Char Bool List Type

" Built-in functions
syn keyword nymFunction length append remove copy reverse sort to_string to_int to_float to_list
syn keyword nymFunction push pop top empty clear contains find split join trim upper lower count index

" Identifiers
syn match nymIdentifier "\<[a-zA-Z_][a-zA-Z0-9_]*\>"

" Operators
syn match nymOperator "\+\|-\|\*\|/\|%\|=\|==\|!=\|<\|>\|<=\|>=\|&&\|||\|!\|&\||\|\^\|~\|<<\|>>\|+=\|-=\|*=\|/=\|%=|\|++\|--\|->\|::"

" Comments
syn match nymComment "#.*$"

" Strings
syn region nymString start=/"/ skip=/\\"/ end=/"/

" Characters (if applicable)
syn region nymCharacter start=/'/ skip=/\\'/ end=/'/

" Numbers
syn match nymNumber "\<\d\+\>"
syn match nymNumber "\<\d\+\.\d*\>"
syn match nymNumber "\<0[xX][0-9a-fA-F]\+\>"
syn match nymNumber "\<0[bB][01]\+\>"

" Define the highlighting
hi def link nymKeyword Keyword
hi def link nymType Type
hi def link nymFunction Function
hi def link nymIdentifier Identifier
hi def link nymOperator Operator
hi def link nymComment Comment
hi def link nymString String
hi def link nymCharacter Character
hi def link nymNumber Number

let b:current_syntax = "nym"