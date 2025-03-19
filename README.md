This was mad with Godot v4.2.1 stable
<br>
<h1>The Concept</h1>
This is a proof-of-concept for a multiplayer First Person Shooter where you play as a mechanical spider which can shoot lazers and can swing around and crawl around in the environment. The game rules are the same as traditional FPS games where the goal is to shoot the opponent, the twist is the it allows the player to use the entire environment as a traversable space hence providing a lot more freedom of movement. 
<br>
<br>
The players can walk on walls, arches, or really any surface on the map, in addition to that the players can also grappel to a close enough surface where normally, reaching via crawling would take time. All of these mechanics combined allow for player tricks which enhance the regular FPS experience.
<br>
<br>
You can get a glimpse at the gameplay below(sorry for bad quality, github doesn't allow very large videos, a better video can be seen <a href="/BetterQuality_GameplayVideo/Multiplayer_GameplayCompressed.mp4">here</a>):
<br>
<video src="https://github.com/user-attachments/assets/d8bdd78a-056b-49b3-b2c4-c5b9f8564214"></video>
<h1>How it Works</h1>
<h3>Player Movement</h3>
The gameplay movement is divided in two parts- The Movement on the Surface and The <a href="https://in.mathworks.com/discovery/inverse-kinematics.html">Inverse Kinematics</a> for animation of legs.
<br>
The movement on the surface is achieved by a method mentioned in one of my projects for mesh surface walking, it's explained in much more detail <a href="https://github.com/KrishnaSonawane8008/Walking-on-Mesh-Surface-in-Godot-4">here</a>.
<br>
<br>
Once the movement is implemented for the player model, grappling is just a case of the movement where the current face is changed to the one hit by a  raycast. Then the position of the player model is lerped from the current position to the one hit by the raycast and no other movement is allowed(except rotation) till the player reaches the hit face, giving the feeling of grappling from one point to other.
<br>
<br>
Now that the movement is setup, you can see how it looks without IK animation:
<br>
<video src="https://github.com/user-attachments/assets/a3c74757-a0c1-4306-8511-33f310394653"></video>
