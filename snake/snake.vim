" Intialize some values and the game board
fun! SnakeGo()
    call SnakeInit()
    call SnakeRun()
endfun

fun! SnakeInit()

    set nocursorline

    syntax match snake '*'
    syntax match wall '|'
    syntax match wall '-'
    syntax match food '#'
    syntax match game "Game Over"

    hi snake guifg=yellow guibg=yellow
    hi wall guifg=cyan guibg=cyan
    hi food guifg=blue guibg=blue
    hi game guifg=cyan guibg=black


    " Set some initial/default variables
    let b:snake = [[2,2],[3,2],[4,2]]  " Starting Snake
    let b:direction = "right"          " Starting Direction
    let b:food = [10,10]               " First food item
    let b:score = 0                    " Set the starting score to 0

    let b:max_col = 65                 " Playable area width
    let b:max_row = 20                 " Playable area height

    " Draw the screen box
    let l:stat = append(0, "-------------------------------------------------------------------")
    for i in range(20)
        let l:stat = append(1, "|                                                                 |")
    endfor
    let l:stat = append(21, "-------------------------------------------------------------------")

    " Draw the initial score
    call SnakeDrawScore()

endfun

" Check to see if the snake has run into itself
fun! SnakeCheckCollision()

    " Coordinates of the head
    let l:head_row = b:snake[-1][0]
    let l:head_col = b:snake[-1][1]

    " Check the head coord against all of the body elements
    for l:s in b:snake[:-2]
        let l:body_row = l:s[0]
        let l:body_col = l:s[1]

        " Return 1 if there is a collision
        if l:head_row == l:body_row && l:head_col == l:body_col
            return 1
        endif
    endfor

    " Return 0 if there is no collision
    return 0

endfun

" Draw the score
fun! SnakeDrawScore()

    " Write the score to the bottom of the screen
    call setpos('.', [0, b:max_row + 3, 2, 0])
    let l:score = " Score: ".b:score
    let l:stat = append(b:max_row + 2, l:score)

    " Delete the old score
    norm! dG

endfun

" Check to see if we have eaten the food
fun! SnakeCheckFood()

    " Get the snake head position
    let l:snake_head_row = b:snake[-1][0]
    let l:snake_head_col = b:snake[-1][1]

    " Get the food position
    let l:food_row = b:food[0]
    let l:food_col = b:food[1]

    " Compare!
    if l:snake_head_row == l:food_row && l:snake_head_col == l:food_col
        return 1
    endif

    return 0

endfun

" Generate a new food position
fun! SnakeGenFood()

    " The offsets here can be adjusted to get closer or further from the wall
    let l:food_row = Random(b:max_row-5) + 3
    let l:food_col = Random(b:max_col-5) + 3
    let b:food = [l:food_row, l:food_col]

endfun

" Draw the new food on the screen
fun! SnakeDrawFood()

    " Get the food position
    let l:row = b:food[0]
    let l:col = b:food[1]

    " Draw the food (Can I find an easy way to do this with a variable?)
    call setpos('.', [0, l:row, l:col, 0])
    norm! r#

endfun

" Clear the snake from the screen
fun! SnakeClear()

    " Replace the old snake with spaces
    for s in b:snake
        let l:row = s[0]
        let l:col = s[1]
        call setpos('.', [0, l:row, l:col, 0])
        " This might be a bad way to do this...
        norm! r .
        call setpos('.', [0, 1, 1, 0])
    endfor

endfun

" Draw the snake on the screen
fun! SnakeDraw()

    " For every snake coordinate, put an * (can this be done with a variable?)
    for s in b:snake
        let l:row = s[0]
        let l:col = s[1]
        call setpos('.', [0, l:row, l:col, 0])
        norm! r*
        call setpos('.', [0, 1, 1, 0])
    endfor

endfun

" Set the direction of the snake path to up
fun! SnakeUp()
    " The snake can't go backwards!
    if b:direction != "down"
        let b:direction = "up"
    endif
endfun

" Set the direction of the snake path to down
fun! SnakeDown()
    " The snake can't go backwards!
    if b:direction != "up"
        let b:direction = "down"
    endif
endfun

" Set the direction of the snake path to left
fun! SnakeLeft()
    " The snake can't go backwards!
    if b:direction != "right"
        let b:direction = "left"
    endif
endfun

" Set the direction of the snake path to right
fun! SnakeRight()
    " The snake can't go backwards!
    if b:direction != "left"
        let b:direction = "right"
    endif
endfun

" Update the game for each cycle
fun! SnakeUpdate()

    " Get the location of the last head position
    let l:last_row = b:snake[-1][0]
    let l:last_col = b:snake[-1][1]

    " Move based on the 'global' variable set above
    if b:direction == "up"

        let l:new_col = l:last_col
        let l:new_row = l:last_row - 1

        " Deal with walls
        if l:new_row == 1
            let b:running = 0
            call SnakeGameOver()
            return 0
        endif

    endif

    if b:direction == "down"

        let l:new_col = l:last_col
        let l:new_row = l:last_row + 1

        " Deal with walls
        if l:new_row == 22
            let b:running = 0
            call SnakeGameOver()
            return 0
        endif

    endif

    if b:direction == "left"

        let l:new_col = l:last_col - 1
        let l:new_row = l:last_row

        " Deal with walls
        if l:new_col == 1
            let b:running = 0
            call SnakeGameOver()
            return 0
        endif

    endif

    if b:direction == "right"

        let l:new_col = l:last_col + 1
        let l:new_row = l:last_row

        if l:new_col == 67
            let b:running = 0
            call SnakeGameOver()
            return 0
        endif

    endif

    " Add a new head sgement based on the direction settings above
    call add(b:snake,[l:new_row, l:new_col])

    " Check to see if the snake runs into itself
    if SnakeCheckCollision() == 1
        let b:running = 0
        call SnakeGameOver()
        return 0
    endif

    " Clear the snake from the screen
    call SnakeClear()

    " Check to see if the snake ate food!
    if SnakeCheckFood() == 0
        " Remove the last segment if we haven't eaten
        let b:snake = b:snake[1:]
    else

        call SnakeGenFood()       " Place new food on the screen
        let b:score += 1          " Update the score
        call SnakeDrawScore()     " Draw the updated score
    endif

    " Draw the updated snake
    call SnakeDraw()

endfun

" Convert the key press into a direction and call that function
fun! UpdateDirection(key_num)

    " Conver the number read from the input to a character
    let l:key = nr2char(a:key_num)

    " Set the direction based on the character
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

" Run the game (after initialization)
fun! SnakeRun()

    " Only run when this variable is 1
    let b:running = 1
    while b:running == 1

        " Draw the food
        call SnakeDrawFood()
        " Draw the snake
        call SnakeUpdate()
        " Update the screen
        redraw

        " Get a key press if one is available
        let l:key_num = getchar(0)

        " Stop running if 'q' (113) is pressed
        if l:key_num == 113
            let b:running = 0
        endif

        " if any other key is pressed, send it to the UpdateDirection function
        " to be interpeted
        if l:key_num != 0
            call UpdateDirection(l:key_num)
        endif

        " Delay between cycles
        sleep 200m

    endwhile

endfun

" Show the 'Game Over' screen info
fun! SnakeGameOver()

    " Set the position for the end title
    let l:row = 10
    let l:col = 24
    call setpos('.', [0, l:row, l:col, 0])

    " Write to the screen
    norm! 15s-- Game Over --

    " Fix the score text
    let l:score = "|                         Score: ".b:score
    while len(l:score) < b:max_col + 1
        let l:score = l:score." "
    endwhile
    let l:score = l:score."|"

    " Add a line with the score (there is probably a better way to make this
    " consistent for both text outputs...
    call append('.', l:score)
    call setpos('.', [0,0,0,0])

endfun

" Random number generator stolen from someone online...
fun! Random(n)
    let l:rnd = localtime() % 0x10000
    let l:rnd = (l:rnd * 31421 + 6927) % 0x10000
    return l:rnd * a:n / 0x10000
endfunc
