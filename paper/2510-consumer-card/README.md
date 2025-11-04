# 一张消费级显卡能支持的大模型应用

在开始之前，请确保已创建集群，并将 kubeconfig 配置到了本地默认路径：
```
~/.kube/config
```

## ComfyUI应用
bash prep\_comfyui.sh
然后在本地界面用ssh建立本机8080端口和开发机8080端口的端口转发，即可在本地用浏览器访问8080端口。
![示例图片](paper/2510-consumer-card/comb.jpg)
生成微信技术博客的四张图片(见上图)的Flux.1-dev的文本prompt分别为:
Astronaut in a jungle, cold color palette, muted colors, very detailed, sharp focus

An awe-inspiring 3D render of a glass bottle magically transformed into a miniature tropical paradise. The pristine white sand glistens beneath the warm sunlight, accompanied by sparkling shells and an intricately detailed palm tree swaying gently. A charming thatched-roof hut and a shimmering blue bottle add to the idyllic beach setting, while the sandy message "Maya "exudes joy and tranquility. The cinematic and illustrative style of the rendering immerses the viewer in a sun-drenched, captivating escape. This 32k, 4D, full HDR, and hyper-realistic masterpiece is a testament to the future of digital art and imaging, redefining visual storytelling through its breathtaking depth and detail., poster, typography, illustration, photo, 3d render, cinematic

A stunning and vibrant artwork of London cityscape, showcasing the iconic Big Ben clock tower as the focal point. The tower stands tall and majestic, with a glowing orange and yellow sunset casting a warm glow over the scene. To the left, a classic red telephone booth adds a touch of traditional British charm, its reflection mirrored in the wet, glistening streets. The streets have a dreamy, watercolor-like quality, with muted grays, vibrant reds, and splashes of blue in the reflections of the buildings and sky. The overall composition is reminiscent of a movie scene, capturing the essence of London in a captivating and artistic way., photo, cinematic, poster, vibrant, painting, illustration, portrait photography

A visually striking dark fantasy portrait of a majestic horse galloping through a stormy, fiery landscape. The horse's glossy black coat is a stark contrast to its vivid, flame-like mane and tail, which seems to be made of real fire. Its glowing, fiery hooves leave a trail of embers behind, while its intense, glistening eyes reflect a fierce, unbridled energy. The background features a haunting, stormy red sky filled with ominous lightning, adding to the overall sense of mystique and intrigue. This captivating image blends the mediums of photo, painting, and portrait photography to create a unique, conceptual art piece., painting, portrait photography, vibrant, photo, conceptual art, dark fantasy


## OpenWebUI应用
bash start\_owu.sh
然后在本地界面用ssh建立本机8080端口和开发机8080端口的端口转发，即可在本地用浏览器访问8080端口。
