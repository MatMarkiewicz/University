sublist :: [a] -> [[a]]
sublist [] = [[]]
sublist (x:xs) = [x:sub | sub <- sublist xs] ++ sublist xs