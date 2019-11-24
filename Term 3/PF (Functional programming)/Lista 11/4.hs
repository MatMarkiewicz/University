
line :: Int -> String
line 0 = ""
line i = "* " ++ (line (i-1))

print_board :: [Int] -> Int -> IO ()
print_board [] i = putStrLn ""
print_board (h:t) i = 
    do  putStr ((show i) ++ ": ")
        putStrLn (line h)
        print_board t (i+1)
      
change_board :: [Int] -> Int -> Int -> [Int]
change_board [] l n = []
change_board (h:t) 1 n = (max 0 (h-n)):t
change_board (h:t) i n = h:(change_board t (i-1) n)

ai_move :: [Int] -> [Int] -> IO ()
ai_move [] l2 = do  putStrLn "Przegrałeś"
ai_move (h:[]) l2 = do  putStrLn "Przegrałeś"
ai_move (0:t) l2 = ai_move t (0:l2)
ai_move (i:t) l2 = 
    do  putStrLn("Następna tura")
        nim_i ((reverse l2) ++ (0:t))

next_move :: [Int] -> Int -> Int -> IO ()
next_move board l n = 
    let new_board = change_board board l n in 
        if (all (\x -> x == 0) new_board) then
            do  putStrLn ("Wygrałeś")
        else 
            do  print_board new_board 1
                putStrLn("Ruch komputera")
                ai_move new_board []

nim_i :: [Int] -> IO ()
nim_i board = 
    do  print_board board 1
        putStrLn "Wybierz linię, z której chcesz usunąć gwiazdki"
        line <- getLine
        putStrLn "Wybierz ile gwiazdek chcesz usunąć"
        num <- getLine
        next_move board (read line) (read num)


nim :: IO ()
nim = nim_i [5,4,3,2,1]