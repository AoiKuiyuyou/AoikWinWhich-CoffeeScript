#/
'use strict'

#/
_fs = require 'fs'
_path = require 'path'
_ = require 'underscore'

#/ add func |endsWith| to String
String::endsWith ?= (s) -> s == '' or @slice(-s.length) == s

#/
is_file = (path) ->
    fstat = null
    try
        fstat = _fs.statSync(path)
    catch err
        return false

    return fstat && fstat.isFile()

find_executable = (prog) ->
    #/ 8f1kRCu
    env_var_PATHEXT = process.env.PATHEXT
    ## can be |undefined|

    #/ 6qhHTHF
    #/ split into a list of extensions
    ext_s = if !env_var_PATHEXT \
        then []
        else env_var_PATHEXT.split(_path.delimiter)

    #/ 2pGJrMW
    #/ strip
    ext_s = (ext.trim() for ext in ext_s)

    #/ 2gqeHHl
    #/ remove empty
    ext_s = (ext for ext in ext_s when ext != '')

    #/ 2zdGM8W
    #/ convert to lowercase
    ext_s = (ext.toLowerCase() for ext in ext_s)

    #/ 2fT8aRB
    #/ uniquify
    ext_s = _.uniq(ext_s)

    #/ 4ysaQVN
    env_var_PATH = process.env.PATH
    #// can be |undefined|
    #//
    #// if has value, there is an ending || in it,
    #//  which results in an ending empty string for the splitting at 3zVznlK

    #/ 6mPI0lg
    dir_path_s = if !env_var_PATH \
        then []
        else env_var_PATH.split(_path.delimiter)
        ## 3zVznlK

    #/ 5rT49zI
    #/ insert empty dir path to the beginning
    #/
    #/ Empty dir handles the case that |prog| is a path, either relative or absolute.
    #/ See code 7rO7NIN.
    dir_path_s.unshift('')

    #/ 2klTv20
    #/ uniquify
    dir_path_s = _.uniq(dir_path_s)

    #/ 6bFwhbv
    exe_path_s = []

    _.each(dir_path_s, (dir_path) ->
        #/ 7rO7NIN
        #/ synthesize a path with the dir and prog
        path = _path.join(dir_path, prog)

        #/ 6kZa5cq
        #/ assume the path has extension, check if it is an executable
        if _.any(ext_s, (ext) -> path.endsWith(ext))
            if is_file(path)
                exe_path_s.push(path)

        #/ 2sJhhEV
        #/ assume the path has no extension
        _.each(ext_s, (ext) ->
            #/ 6k9X6GP
            #/ synthesize a new path with the path and the executable extension
            path_plus_ext = path + ext

            #/ 6kabzQg
            #/ check if it is an executable
            if is_file(path_plus_ext)
                exe_path_s.push(path_plus_ext)
        )
    )

    #/ 8swW6Av
    #/ uniquify
    exe_path_s = _.uniq(exe_path_s)

    #/
    return exe_path_s

println = (txt) ->
    process.stdout.write(txt + '\n')

main = ->
    #/ 9mlJlKg
    #/ check if one cmd arg is given
    arg_s = process.argv.slice(2)

    if arg_s.length != 1
        #/ 7rOUXFo
        #/ print program usage
        println 'Usage: aoikwinwhich PROG'
        println ''
        println '#/ PROG can be either name or path'
        println 'aoikwinwhich notepad.exe'
        println 'aoikwinwhich C:\\Windows\\notepad.exe'
        println ''
        println '#/ PROG can be either absolute or relative'
        println 'aoikwinwhich C:\\Windows\\notepad.exe'
        println 'aoikwinwhich Windows\\notepad.exe'
        println ''
        println '#/ PROG can be either with or without extension'
        println 'aoikwinwhich notepad.exe'
        println 'aoikwinwhich notepad'
        println 'aoikwinwhich C:\\Windows\\notepad.exe'
        println 'aoikwinwhich C:\\Windows\\notepad'

        #/ 3nqHnP7
        return

    #/ 9m5B08H
    #/ get name or path of a program from cmd arg
    prog = arg_s[0]

    #/ 8ulvPXM
    #/ find executables
    path_s = find_executable(prog)

    #/ 5fWrcaF
    #/ has found none, exit
    if !path_s.length
        #/ 3uswpx0
        return

    #/ 9xPCWuS
    #/ has found some, output
    txt = path_s.join('\n')

    println txt

    #/ 4s1yY1b
    return

#/
exports.main = main

#/
if require.main == module
    main()
