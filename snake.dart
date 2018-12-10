import 'dart:html';
import 'dart:math';
import 'dart:collection'; 
import 'dart:async'; 

const int CELL_SIZE = 10; 
const int START_LENGTH = 6;

CanvasElement canvas;  
CanvasRenderingContext2D ctx;
Keyboard keyboard = new Keyboard();  


void main() {  
  canvas = querySelector('#canvas')..focus();
  ctx = canvas.getContext('2d');
  
  clear(0,0);
	new Game()..run();
  
  //drawCell(new Point(10, 10), "salmon");
  //Snake s1 = new Snake();
  //print(s1._body);
  //s1.update();
}

void drawCell(Point coords, String color) {  
  ctx..fillStyle = color
    ..strokeStyle = "white";

  final int x = coords.x * CELL_SIZE;
  final int y = coords.y * CELL_SIZE;

  ctx..fillRect(x, y, CELL_SIZE, CELL_SIZE)
    ..strokeRect(x, y, CELL_SIZE, CELL_SIZE);
}

void clear(int a, int b) {  
  ctx..fillStyle = "blue";
    ctx.fillRect(0, 0, canvas.width, canvas.height);
  
  ctx.font = "30px Arial ";
  ctx.textAlign = 'center';
  ctx.strokeText('Snake',canvas.width/2, 30);
  
  ctx.strokeText('P1:'+a.toString()+' P2:'+b.toString(),canvas.width/2, canvas.height/2);
}

class Keyboard {  
  HashMap<int, num> _keys = new HashMap<int, num>();

  Keyboard() {
    window.onKeyDown.listen((KeyboardEvent event) {
      _keys.putIfAbsent(event.keyCode, () => event.timeStamp);
    });

    window.onKeyUp.listen((KeyboardEvent event) {
      _keys.remove(event.keyCode);
    });
  }

  bool isPressed(int keyCode) => _keys.containsKey(keyCode);
}

class Snake {

  // directions
static const Point LEFT = const Point(-1, 0);  
static const Point RIGHT = const Point(1, 0);  
static const Point UP = const Point(0, -1);  
static const Point DOWN = const Point(0, 1); 
  
  // coordinates of the body segments
List<Point> _body;
  
  // current travel direction
Point _dir = RIGHT;
  
Point get head => _body.first;
  
var color = 'abc';
  var y = 5;
  var score = 0;
  
/*Snake() { 
  print("in constructor");
  int i = START_LENGTH - 1;
  _body = new List<Point>.generate(START_LENGTH,
    (int index) => new Point(i--, this.y));
	}*/

Snake(String c, int y){
  this.color = c;
  this.y = y;
  print("in constructor");
  int i = START_LENGTH - 1;
  _body = new List<Point>.generate(START_LENGTH,
    (int index) => new Point(i--, this.y));
}
  
void _checkInput() {
  if(this.color == 'green'){
  if (keyboard.isPressed(KeyCode.LEFT) && _dir != RIGHT) {
    _dir = LEFT;
  }
  else if (keyboard.isPressed(KeyCode.RIGHT) && _dir != LEFT) {
    _dir = RIGHT;
  }
  else if (keyboard.isPressed(KeyCode.UP) && _dir != DOWN) {
    _dir = UP;
  }
  else if (keyboard.isPressed(KeyCode.DOWN) && _dir != UP) {
    _dir = DOWN;
  }
  }
  
  else{
  if (keyboard.isPressed(KeyCode.A) && _dir != RIGHT) {
    _dir = LEFT;
  }
  else if (keyboard.isPressed(KeyCode.D) && _dir != LEFT) {
    _dir = RIGHT;
  }
  else if (keyboard.isPressed(KeyCode.W) && _dir != DOWN) {
    _dir = UP;
  }
  else if (keyboard.isPressed(KeyCode.S) && _dir != UP) {
    _dir = DOWN;
  }  
  }
  
	}
  
 void grow() {  
  // add new head based on current direction
   if(this.head.x >= 44)
   {
     _body.insert(0, Point(0,this.head.y) + _dir);
   }
   else if(this.head.x <= -1)
   {
     _body.insert(0, Point(44,this.head.y) + _dir);
   }
   else if(this.head.y >= 44)
   {
     _body.insert(0, Point(this.head.x,0) + _dir);
   }
   else if(this.head.y <= -1)
   {
     _body.insert(0, Point(this.head.x,44) + _dir);
   }
   
   else _body.insert(0, head + _dir);
	}
  
  void _move() {  
  // add a new head segment
  grow();

  // remove the tail segment
  _body.removeLast();
	}
  
  void _draw() {  
  // starting with the head, draw each body segment
  for (Point p in _body) {
    drawCell(p, this.color);
  }
	}
  
  bool checkForBodyCollision() {  
  for (Point p in _body.skip(1)) {
    if (p == head) {
      return true;
    }
  }

  return false;
	}
  
  void update() {  
  _checkInput();
  _move();
  _draw();
	}  
}

class Game {
  
  // smaller numbers make the game run faster
static const num GAME_SPEED = 50;
num _lastTimeStamp = 0; 
  
// a few convenience variables to simplify calculations
int _rightEdgeX;  
int _bottomEdgeY; 
  
  Snake _snake;
  Snake _snake2;
Point _food;
  
  Game() {  
  _rightEdgeX = canvas.width ~/ CELL_SIZE;
  _bottomEdgeY = canvas.height ~/ CELL_SIZE;
    
    

  init();
}
  
  void init() {  
  _snake = new Snake('green',1);
  _snake2 = new Snake('red', 43);
  _food = _randomPoint();
}
  
  Point _randomPoint() {  
  Random random = new Random();
  return new Point(random.nextInt(_rightEdgeX),
    random.nextInt(_bottomEdgeY));
}
  
  void _checkForCollisions(Snake s) {  
  // check for collision with food
  if (s.head == _food){
    s.score++;
    s.grow();
    _food = _randomPoint();
  }
    

  // check death conditions
  if (/*s.head.x <= -1 ||
    s.head.x >= _rightEdgeX ||
    s.head.y <= -1 ||
    s.head.y >= _bottomEdgeY ||*/
    s.checkForBodyCollision()) {
    init();
  }
}
  
  Future run() async {  
  update(await window.animationFrame);
}
  
  void update(num delta) {  
  final num diff = delta - _lastTimeStamp;

  if (diff > GAME_SPEED) {
    _lastTimeStamp = delta;
    clear(_snake.score,_snake2.score);
    drawCell(_food, "black");
    _snake.update();
    _snake2.update();
    _checkForCollisions(_snake);
    _checkForCollisions(_snake2);
  }

  // keep looping
  run();
}

}
