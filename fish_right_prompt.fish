# Set these options in your config.fish (if you want to :])
#
#     set -g theme_display_git_user no
#     set -g theme_display_hg_user yes
#     set -g theme_display_date yes
#     set -g theme_date_format "+%c"

#
# Segments functions
#
set -g current_bg NONE
set -g segment_right_separator \uE0B2

function right_prompt_segment -d "Function to draw a right segment"
  set -l bg
  set -l fg
  if [ -n "$argv[1]" ]
    set bg $argv[1]
  else
    set bg normal
  end
  if [ -n "$argv[2]" ]
    set fg $argv[2]
  else
    set fg normal
  end
  if [ "$current_bg" != 'NONE' -a "$argv[1]" != "$current_bg" ]
    set_color -b $current_bg
  else
    set_color -b normal
  end
  set_color $bg
  echo -n " $segment_right_separator"
  set_color -b $bg
  set_color $fg
  set current_bg $argv[1]
  if [ -n "$argv[3]" ]
    echo -n -s " " $argv[3]
  end
end

function right_prompt_finish -d "Close open segments"
  if [ -n $current_bg ]
    echo -n " "
  end
  set_color -b normal
  set_color normal
  set -g current_bg NONE
end


#
# Components
#

function right_prompt_hg_user -d "Display mercurial user"
  if [ "$theme_display_hg_user" != 'yes' ]
    return
  end

  if command hg id >/dev/null 2>&1
    set user_name (command hg config ui.username ^/dev/null)
    if [ $user_name ]
      set user_name (command echo $user_name | sed -e 's/<.*>//g' | sed -e 's/ *$//g')
      right_prompt_segment cyan $shellder_white $user_name
    else
      right_prompt_segment blue $shellder_white '-'
    end
  end
end

function right_prompt_git_user -d "Display the current git user"
  if [ "$theme_display_git_user" = 'no' ]
    return
  end

  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
    set -l user_config; set -l user_name;

    set user_name (command git config --local --get user.name ^/dev/null)
    set user_config local
    if [ ! $user_name ]
      set user_name (command git config --global --get user.name ^/dev/null)
      set user_config global
      if [ ! $user_name ]
        set user_name '-'
        set user_config not
      end
    end

    if [ $user_name ]
      switch $user_config
        case 'local'
          right_prompt_segment red $shellder_white $user_name
        case 'global'
          right_prompt_segment cyan $shellder_white $user_name
        case 'not'
          right_prompt_segment blue $shellder_white $user_name
      end
    end
  end
end

function right_prompt_timestamp -S -d 'Display current timestamp'
  if [ "$theme_display_date" != 'yes' ]
    return
  end

  set -q theme_date_format; or set -l theme_date_format "+%H:%M"
  right_prompt_segment black BCBCBC (date $theme_date_format)
end


#
# Prompt
#
function fish_right_prompt
  set_color --print-colors | grep -q grey; and set -g shellder_white grey; or set -g shellder_white white
  type -q hg; and right_prompt_hg_user
  type -q git; and right_prompt_git_user
  right_prompt_timestamp
  right_prompt_finish
end
