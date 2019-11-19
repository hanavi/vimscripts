fun! SnakeInit()
    let stat = append(0, "-------------------------------------------------------------------")
    for i in range(20)
        let stat = append(1, "|                                                                 |")
    endfor
    let stat = append(21, "-------------------------------------------------------------------")

    let b:snake = [[2,2],[3,2],[4,2]]
    let b:direction = "right"

endfun

fun! SnakeClear()
    for s in b:snake
        let row = s[0]
        let col = s[1]
        call setpos('.', [0, row, col, 0])
        " This might be a bad way to do this...
        norm! r .
        call setpos('.', [0, 1, 1, 0])
    endfor
endfun

fun! SnakeDraw()
    for s in b:snake
        let row = s[0]
        let col = s[1]
        call setpos('.', [0, row, col, 0])
        norm! r*
        call setpos('.', [0, 1, 1, 0])
    endfor
endfun

fun! SnakeUp()
    if b:direction != "down"
        let b:direction = "up"
    endif
endfun

fun! SnakeDown()
    if b:direction != "up"
        let b:direction = "down"
    endif
endfun

fun! SnakeLeft()
    if b:direction != "right"
        let b:direction = "left"
    endif
endfun

fun! SnakeRight()
    if b:direction != "left"
        let b:direction = "right"
    endif
endfun

fun! SnakeUpdate()
    let last_row = b:snake[-1][0]
    let last_col = b:snake[-1][1]

    if b:direction == "up"

        let new_col = last_col
        let new_row = last_row - 1

        if new_row == 1
            let new_row = 21
        endif
    endif

    if b:direction == "down"

        let new_col = last_col
        let new_row = last_row + 1

        if new_row == 21
            let new_row = 2
        endif
    endif

    if b:direction == "left"

        let new_col = last_col - 1
        let new_row = last_row

        if new_col == 1
            let new_col = 66
        endif
    endif

    if b:direction == "right"

        let new_col = last_col + 1
        let new_row = last_row

        if new_col == 67
            let new_col = 2
        endif
    endif

    call add(b:snake,[new_row, new_col])
    call SnakeClear()
    let b:snake = b:snake[1:]
    call SnakeDraw()

endfun

fun! UpdateDirection(key_num)


    let key = nr2char(a:key_num)

    if key == 'j'
        call SnakeDown()
    elseif key == 'k'
        call SnakeUp()
    elseif key == 'h'
        call SnakeLeft()
    elseif key == 'l'
        call SnakeRight()
    endif

endfun

fun! SnakeRun()
    let b:running = 1
    while b:running == 1
        call SnakeUpdate()
        redraw
        let key_num = getchar(0)

        if key_num == 113
            let b:running = 0
        endif

        if key_num != 0
            call UpdateDirection(key_num)
        endif

        sleep 200m
    endwhile
endfun
