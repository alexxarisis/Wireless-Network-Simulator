## -*- texinfo -*-
## @deftypefn  {} {@var{wnd} =} mainDialog ()
##
## Create and show the dialog, return a struct as representation of dialog.
##
## @end deftypefn

function main()
  addPaths()
  mainDialog_def;
  show_mainDialog();
end

function addPaths()
  addpath("src/")
  addpath("src/room")
  addpath("src/scenario1")
  addpath("src/scenario2")
  addpath("src/resources")
  addpath("src/resources/data")
  addpath("src/resources/images")
end
