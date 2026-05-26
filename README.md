# Blitzball Pico8

## What is it?
This is a fun side project that I've been working on while applying for jobs based on Jomboys Blitzball, a wiffleball'esque game. [Link to video](https://www.youtube.com/watch?v=tQaboKY-nMU)

## TLDR Rules of Blitzball
- 5 Balls
- 3 Strikes
- Depending on where the ball lands, the player moves ghost runners

## Pico8 

Pico8 is a "Fantasy Console" that emulates a  8bit console. [Website](https://www.lexaloffle.com/pico-8.php)

## Testing

Right now, you can run unit tests by running `pico8 -x tests.p8` if you have pico8 command running in your terminal. I'll had instructions for later on how to do that, as I went through a few iterations to make it work. 

## Why This?
I thought it would be fun! Nice way to learn more about Pico8 and Lua scripting. Also, it's a good way to practice my skills and logic. 

## How to play
As of right now, you can play as the batter, move with 2nd player controls. The pitcher AI will throw balls at you randomly

## To do (In no order) 
- Finish basic game loop (3 outs, game over)
- Add more robust Pitching AI (When to throw strike/ball, move around the mound)
- Implement homeruns
- Implement a messaging system to let player know what is happening
- Complete refactor of game 'class'

## Use of AI 
Use of AI in this project is minimal, mostly helping me when I get stuck on physics / really obscure Pico8 Commands. It was INCREDIBLY useful in helping me figure out how to make terminal testing work! 
