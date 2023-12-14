## -*- texinfo -*-
## @deftypefn  {} {@var{wnd} =} mainDialog ()
##
## Create and show the dialog, return a struct as representation of dialog.
##
## @end deftypefn

function main()
  addPaths();
  mainDialog_def;
  show_mainDialog();
end

function addPaths()
  srcPath = [pwd(), "\\src"];
  addpath(srcPath);
  addpath([srcPath, "\\room"]);
  addpath([srcPath, "\\scenario1"]);
  addpath([srcPath, "\\scenario2"]);

  resourcesPath = [srcPath, "\\resources"];
  addpath(resourcesPath);
  addpath([resourcesPath, "\\data"]);
  addpath([resourcesPath, "\\images"]);
end
