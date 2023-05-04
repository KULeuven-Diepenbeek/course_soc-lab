---
title: 'Project'
chapter: true
weight: 500
draft: false
---

# Project requirements

The goal of the project was to make a xmas-light string of PYNQ boards. So your board should be able to receive a command, run it on the xmas-light and send it to the next one. 

The code you need to create as that it keeps listening for a message, if it receives a message then it needs to send this message to the xmas-lights. Afterwards it will send the same message that is received back.

{{% figure src="/img/ch_project/evaluation_message.png" title="Example evaluation messsage" %}}

The goal is that during evaluation your board receives a message, executes the command on the xmas lights and send the same command back. During evuluation I will monitor if the command that is received is the same that is send and that the board does the right function.

### What if project is not complete?

All students are required to upload **all** the hardware code (not the block diagram) used in the project, include the code used in the ip components. If your hardware block doesn't work during project demonstration the code would be analysed to see the progress. It is also required to upload the file which contains the software you have written and/or copied from the course.

If only 1 IP block works in the hardware you can also demonstrate only this component. If for example only the xmas light works you can also demonstrate this. The more you can show works, the more points you get.