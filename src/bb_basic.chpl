use Time;
use IO;
use Math;
use List;
use Random;

// config const N = 280; 
config const N = 280; 
config const file = "data/a280.tsp"; 

var timer: Timer;
// var localMin: real = 99999999999;
// var localMinPath: list(int);
// here.maxTaskPar;

proc random(min: int, max: int): int{
    var rands: [1..1] real;
    fillRandom(rands);
    var rand = 1 + rands[1] * N;
    var ret = rand: int;
    return ret;
}

proc euclidean_distance((x1, y1): 2*int, (x2, y2): 2* int): real {
    var xDistance = abs(x1 - x2);
    var yDistance = abs(y1 - y2);
    return sqrt(xDistance * xDistance + yDistance * yDistance);
}

proc tsplib_reader(path: string, n: int) : []real {
    var file = open(path, iomode.r);
    var readingChannel = file.reader();
    var nodes: [1..n] (int, int);
    var adj: [1..n, 1..n] real;

    forall i in nodes.domain {
        var node, x, y: int;
        readingChannel.readln(node, x, y);
        nodes(node) = (x, y);
    }
    file.close();

    forall (i, j) in adj.domain {
        if (i != j) {
            adj(i, j) = euclidean_distance(nodes(i), nodes(j));
            // writeln(adj(i, j));
        }
    }    
    return adj;
}

proc tree_branch(in distance: real, adj: []real, in path , inout localMin: real, inout localMinPath) {

    if (path.size == N) {
        distance += adj(path[path.size], path[1]);
        if (distance < localMin) {
            path.append(path[1]);
            localMin = distance;
            localMinPath = path;
        }
        return;
    }  

    for i in 1..N {
        if (path.contains(i)) {
            continue;
        }
        var newDistance = distance + adj(path[path.size], i);

        if (newDistance < localMin) {
            path.append(i);
            tree_branch(newDistance, adj, path, localMin, localMinPath);
            path.pop();
        } 
    }
}

proc main() {

    var adj = tsplib_reader(file, N);
    // var adj: [1..N, 1..N] real;
    // adj(1,2) = 35;adj(2,1) = 35;adj(1,3) = 25;adj(3,1) = 25;adj(1,4) = 10;adj(4,1) = 10;adj(2,3) = 30;adj(3,2) = 30;
    // adj(2,4) = 15;adj(4,2) = 15;adj(3,4) = 20;adj(4,3) = 20;

    var root = random(1,N);
    writeln("root node:\t\t", root);
    
    var minArray: [1..N] real;
    var minPathArray: [1..N] list(int);
    minArray[root] = 99999999999;

    timer.start();
    
    coforall node in 1..N {
        if node != root {
            var path: list(int);
            var distance = adj(root, node): real;

            path.append(root);
            path.append(node);

            var localMin: real = 99999999999;
            var localMinPath: list(int);

            tree_branch(distance, adj, path, localMin, localMinPath);

            minArray[node] = localMin;
            minPathArray[node] = localMinPath;
            
        }
    }

    timer.stop();

    var (minVal, minLoc) = minloc reduce zip(minArray, minArray.domain);
    writeln("time:\t\t\t", timer.elapsed(), " s");
    writeln("global best path:\t", minPathArray[minLoc]);
    writeln("global min distance:\t", minVal);
}

