---
title: 'Project'
chapter: true
weight: 500
draft: true
---

# Project requirements

Because the original goal was to implement encryption the communicator can send 32 bits of data at the same time. When we are not doing encryption we will put our command at the end of the 32 bit message.

The code you need to create as that it keeps listening for a message, if it receives a message then it needs to extract the command part out of it and turn on the xmas lights. Then it will send the same message that is received back.

{{% figure src="/img/ch_project/evaluation_message.png" title="Example evaluation messsage" %}}

The goal is that during evaluation your board receives a message, executes the command on the xmas lights and send the same command back.

### What if project is not complete?

All students are required to upload **all** the hardware code (not the block diagram) used in the project, include the code used in the ip components. If your hardware block doesn't work during project demonstration the code would be analysed to see the progress.

If only 1 IP block works in the hardware you can also demonstrate only this component. If for example only the xmas light works you can also demonstrate this. The more you can show works, the more points you get.