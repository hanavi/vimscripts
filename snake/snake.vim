fun! SnakeInit()
    let l:stat = append(0, "-------------------------------------------------------------------")
    for i in range(20)
        let l:stat = append(1, "|                                                                 |")
    endfor
    let l:stat = append(21, "-------------------------------------------------------------------")

    let b:snake = [[2,2],[3,2],[4,2]]
    let b:direction = "right"
    let b:food = [10,10]
    let b:max_col = 65
    let b:max_row = 20
    let b:score = 0
    call SnakeDrawScore()
endfun

fun! SnakeCheckCollision()
    let l:head_row = b:snake[-1][0]
    let l:head_col = b:snake[-1][1]

    for l:s in b:snake[:-2]
        let l:body_row = l:s[0]
        let l:body_col = l:s[1]

        if l:head_row == l:body_row && l:head_col == l:body_col
            return 1
        endif
    endfor
    return 0
endfun

fun! SnakeDrawScore()
    call setpos('.', [0, b:max_row + 3, 2, 0])
    " norm 50sScore: b:score
    let l:score = " Score: ".b:score
    let l:stat = append(b:max_row + 2, l:score)
    norm! dG
endfun

fun! SnakeCheckFood()
    let l:snake_head_row = b:snake[-1][0]
    let l:snake_head_col = b:snake[-1][1]

    let l:food_row = b:food[0]
    let l:food_col = b:food[1]

    if l:snake_head_row == l:food_row && l:snake_head_col == l:food_col
        return 1
    endif
    return 0
endfun

fun! SnakeGenFood()
    let l:food_row = Random(b:max_row-5) + 3
    let l:food_col = Random(b:max_col-5) + 3
    let b:food = [l:food_row, l:food_col]
endfun

fun! SnakeDrawFood()
    let l:row = b:food[0]
    let l:col = b:food[1]
    call setpos('.', [0, l:row, l:col, 0])
    norm! r#
endfun

fun! SnakeClear()
    for s in b:snake
        let l:row = s[0]
        let l:col = s[1]
        call setpos('.', [0, l:row, l:col, 0])
        " This might be a bad way to do this...
        norm! r .
        call setpos('.', [0, 1, 1, 0])
    endfor
endfun

fun! SnakeDraw()
    for s in b:snake
        let l:row = s[0]
        let l:col = s[1]
        call setpos('.', [0, l:row, l:col, 0])
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
    let l:last_row = b:snake[-1][0]
    let l:last_col = b:snake[-1][1]

    if b:direction == "up"

        let l:new_col = l:last_col
        let l:new_row = l:last_row - 1

        if l:new_row == 1
            let b:running = 0
            call SnakeGameOver()
        endif
    endif

    if b:direction == "down"

        let l:new_col = l:last_col
        let l:new_row = l:last_row + 1

        if l:new_row == 22
            let b:running = 0
            call SnakeGameOver()
        endif
    endif

    if b:direction == "left"

        let l:new_col = l:last_col - 1
        let l:new_row = l:last_row

        if l:new_col == 1
            let b:running = 0
            call SnakeGameOver()
        endif
    endif

    if b:direction == "right"

        let l:new_col = l:last_col + 1
        let l:new_row = l:last_row

        if l:new_col == 67
            let b:running = 0
            call SnakeGameOver()
        endif
    endif

    call add(b:snake,[l:new_row, l:new_col])
    if SnakeCheckCollision() == 1
        let b:running = 0
        call SnakeGameOver()
    endif
    let l:eat = SnakeCheckFood()
    call SnakeClear()
    if l:eat == 0
        let b:snake = b:snake[1:]
    else
        call SnakeGenFood()
        let b:score += 1
        call SnakeDrawScore()
    endif
    call SnakeDraw()

endfun

fun! UpdateDirection(key_num)

    let l:key = nr2char(a:key_num)

    if l:key == 'j'
        call SnakeDown()
    elseif l:key == 'k'
        call SnakeUp()
    elseif l:key == 'h'
        call SnakeLeft()
    elseif l:key == 'l'
        call SnakeRight()
    endif

endfun

fun! SnakeRun()
    let b:running = 1
    while b:running == 1
        call SnakeDrawFood()
        call SnakeUpdate()
        redraw
        let l:key_num = getchar(0)

        if l:key_num == 113
            let b:running = 0
        endif

        if l:key_num != 0
            call UpdateDirection(l:key_num)
        endif

        sleep 200m
    endwhile
endfun

fun! SnakeGameOver()
    call SnakeClear()
    let l:row = 10
    let l:col = 24
    call setpos('.', [0, l:row, l:col, 0])
    norm! 15s-- Game Over --
    let l:score = "|                         Score: ".b:score
    while len(l:score) < b:max_col + 1
        let l:score = l:score." "
    endwhile
    let l:score = l:score."|"
    call append('.', l:score)
endfun

fun! Random(n)
    let l:rnd = localtime() % 0x10000
    let l:rnd = (l:rnd * 31421 + 6927) % 0x10000
    return l:rnd * a:n / 0x10000
endfunc
