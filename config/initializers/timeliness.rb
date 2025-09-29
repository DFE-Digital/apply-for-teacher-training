# Time formats for timeliness are defined here: https://github.com/adzap/timeliness/blob/master/lib/timeliness/definitions.rb

Timeliness.add_formats('time', 'h[.]?')             # Allow 12/24 hour time with no minutes e.g. 14 = 2:00pm, 5 = 5am
Timeliness.add_formats('time', 'h_nn')              # Allow 12/24 hour format without punctuation or am/pm
Timeliness.add_formats('time', 'h_nn_ampm')         # Allow 12 hour format without punctuation between hours and minutes
Timeliness.add_formats('time', 'h[:.]_ampm')        # Allow 12 hour format with am/pm separated by .
Timeliness.add_formats('time', 'h[:.]?_nn_._ampm')  # Allow hours and minutes separated with : or . and with am/pm separated by .
