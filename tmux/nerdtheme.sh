# vim:filetype=tmux
#### COLOUR
#tm_color_active=colour32
#tm_color_inactive=colour241
#tm_color_feature=colour206
#tm_color_music=colour215
#tm_active_border_color=colour240
#tm_color_status=colour22

tm_color_active=colour32
tm_color_inactive=colour22
tm_color_feature=colour10
tm_color_music=colour215
tm_active_border_color=colour10
tm_color_status=colour0
tm_color_time=colour15

# separators
tm_separator_left_bold="◀"
tm_separator_left_thin="❮"
tm_separator_right_bold="▶"
tm_separator_right_thin="❯"

set -g status-left-length 32
set -g status-right-length 150
set -g status-interval 5

# default statusbar colors
# set-option -g status-bg colour0
set-option -g status-fg $tm_color_active
set-option -g status-bg $tm_color_status
set-option -g status-attr default

# default window title colors
set-window-option -g window-status-fg $tm_color_inactive
set-window-option -g window-status-bg default
set -g window-status-format "#I #W"

# active window title colors
set-window-option -g window-status-current-fg $tm_color_active
set-window-option -g window-status-current-bg default
set-window-option -g  window-status-current-format "#[bold]#I #W"

# pane border
set-option -ag pane-active-border-style "bg=$tm_color_status,fg=$tm_active_border_color"
set-option -ag pane-border-style "bg=$tm_color_status,fg=$tm_color_inactive"

# message text
set-option -g message-bg default
set-option -g message-fg $tm_color_active

# pane number display
# set-option -g display-panes-active-colour $tm_color_active
# set-option -g display-panes-colour $tm_color_inactive

# clock
set-window-option -g clock-mode-colour $tm_color_time

# tm_tunes="#[fg=$tm_color_music]#(osascript ~/.dotfiles/applescripts/tunes.scpt | cut -c 1-50)"

# Set the Battery
if-shell '[[ $CONFIG_DOT_BATTERY == YES ]]' \
  'tm_battery="#[fg=default]#(battery)"' \
  'tm_battery=""'

# Set the Music
if-shell '[[ $CONFIG_DOT_MUSIC == YES ]]' \
  'tm_music="#[fg=$tm_color_music]#(music)"' \
  'tm_music=""'

tm_date="#[fg=$tm_color_time] %R %b %d"
# tm_host="#[fg=$tm_color_feature,bold]#h"
tm_session_name="#[fg=$tm_color_feature,bold]#S"

set -g status-left "$tm_session_name "
set -g status-right "$tm_music $tm_battery $tm_date"

