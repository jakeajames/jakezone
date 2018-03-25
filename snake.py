#snake game for micro:bit. Written in Python. First python project, ever

from microbit import *
import random

direction = 0 #to the right
snake = [[2,1], [3,1]] #initial coordinates
shalladdfood = True
score = 0
food = [random.randint(0, 4), random.randint(0, 4)]
speed = 500

while True:
  display.clear() 
  #add food
  display.set_pixel(food[0], food[1], 9)
  if shalladdfood:
    food = [random.randint(0, 4), random.randint(0, 4)]
    shalladdfood = False
  #add snake  
  isHead = True
  for part in snake[::-1]:
    if isHead:
      display.set_pixel(part[0], part[1], 9)
      isHead = False
      if [part[0], part[1]] in snake[::-1][1:]:
        display.clear()
        display.scroll(":( - Score: " + str(score))
        break
        break
      #higher score, faster the snake    
      if(part[0] == food[0] and part[1] == food[1]):
        score += 10
        if speed > 200:
           speed -= 100
        
        if direction % 4 == 0: #right
          newXY = [snake[0][0]-1, snake[0][1]]
        elif direction % 4 == 1: #down
          newXY = [snake[0][0], snake[0][1]-1]
        elif direction % 4 == 2: #left
          newXY = [snake[0][0]+1, snake[0][1]]
        elif direction % 4 == 3: #up
          newXY = [snake[0][0], snake[0][1]+1]
        shalladdfood = True
        snake = [newXY] + snake
    else:
      if part[0] >= 0 and part[0] <= 4 and part[1] >= 0 and part[1] <= 4:
        display.set_pixel(part[0], part[1], 4)

  oldsnake = [part[:] for part in snake]
  #change direction
  if button_a.was_pressed():
    direction += 3
  elif button_b.was_pressed():
    direction += 1     
    
  if direction % 4 == 0:
    snake[-1][0] += 1
    if snake[-1][0] == 5:
      snake[-1][0] = 0
  elif direction % 4 == 1:
    snake[-1][1] += 1
    if snake[-1][1] == 5:
      snake[-1][1] = 0
  elif direction % 4 == 2:
    snake[-1][0] -= 1
    if snake[-1][0] == -1:
      snake[-1][0] = 4
  elif direction % 4 == 3:
    snake[-1][1] -= 1
    if snake[-1][1] == -1:
      snake[-1][1] = 4
      
  for i in range(0, len(snake)-1):
      snake[i] = oldsnake[i+1][:]
           
  sleep(speed)
