#!/usr/bin/env fish

function repository -d "Local repositories management tool"
 switch count $argv
   case 1
     echo '1 argumento'
   case 2
     echo '2 argumento'
   case 3
     echo '3 argumento'
 end
end
