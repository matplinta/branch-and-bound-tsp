use Time;
use IO;
use Math;
use List;
use Random;

config const initRoot = -1;
config const N = 280; 
config const file = "data/a280.tsp"; 
config const split = 1;
const MAX_INTEGER = 999999999;

var globalMin: atomic real;
var globalMinPathLoc: atomic int;
var timer: Timer;

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

proc tree_branch(in distance: real, adj: []real, in path, inout minPath) {

    if (path.size == N) {
        distance += adj(path[path.size], path[1]);
        if (distance < globalMin.read()) {
            path.append(path[1]);
            globalMin.write(distance);
            minPath = path;
            globalMinPathLoc.write(path[2]);
        }
        return;
    }  
    for i in 1..N {
        if (path.contains(i)) {
            continue;
        }
        var newDistance = distance + adj(path[path.size], i);

        if (newDistance < globalMin.read()) {
            path.append(i);
            tree_branch(newDistance, adj, path, minPath);
            path.pop();
        } 
    }
}

proc main() {

    // READ TSPLIB DATA
    var adj = tsplib_reader(file, N);

    // INIT VARIABLES
    var root =  if initRoot == -1 then random(1,N) else initRoot;
    globalMin.write(MAX_INTEGER);
    var newGlobalMin: bool;
    var minArray: [1..N] real;
    var minPathArray: [1..N] list(int);
    var ranges: [1..#split] list(int);
    minArray[root] = MAX_INTEGER;
    var path, minPath: list(int);
    path.append(root);

    // INIT RANGES ARRAY
    for branch in 1..N do {
        if branch == root { continue; }
        ranges[branch % split + 1].append(branch);
    } 

    writeln("INF: ranges array:\t", ranges);

    timer.start();
    
    coforall process in 1..split with (in path, in minPath, in newGlobalMin) do {
        for node in ranges[process] {
            var distance = adj(root, node): real;
            path.append(node);
            tree_branch(distance, adj, path, minPath);
            minPathArray[node] = minPath;
            path.pop();
        }
        writeln("INF: ", process, " process exited.");
    }

    timer.stop();

    writeln("INF: Global best path:\t", minPathArray[globalMinPathLoc.read()]);
    writeln(root, ",", globalMin.read(), ",", timer.elapsed());
}

