@default_files = ('main.tex');
$pdf_mode = 4;  # use lualatex
$jobname = "./build/main";
# '--shell-escape' required for minted
set_tex_cmds( '--shell-escape -interaction=nonstopmode %O %S' );
