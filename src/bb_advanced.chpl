use Time;
use IO;
use Math;
use List;


// config const N = 280; 
config const N = 4; 
config const TASKS = 3;
var globalMin: real = 99999999999;
var globalMinPath: list(int);
// here.maxTaskPar;

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


// var adj = tsplib_reader("data/a280.tsp", N);
var adj: [1..N, 1..N] real;
adj(1,2) = 35;
adj(2,1) = 35;
adj(1,3) = 25;
adj(3,1) = 25;
adj(1,4) = 10;
adj(4,1) = 10;
adj(2,3) = 30;
adj(3,2) = 30;
adj(2,4) = 15;
adj(4,2) = 15;
adj(3,4) = 20;
adj(4,3) = 20;

// proc branches(root: int, nodes: []int, adj: []real): []int {
//     var visited: [1..N] bool;
//     visited(root) = true;
//     // var currentPath = List.init();
//     var globalMin = 99999999999;
//     // for i in nodes {

//     // }

// }

// proc branch_rec(adj: []real, rootWeight: real, currWeight: real, level: int, currPath: [] int, visited: []bool) {

//     if (level == N) {
//         localMin = currWeight + adj(currPath[level - 1], currPath[0]);

//         if (localMin < globalMin) {
//             globalMin = localMin;
//         }

//         return localMin;
//     }  

//     for (i in 1..N) {
//         if (visited(i) == false) {
//             var temp = rootWeight;
//             currWeight += adj(currPath[level - 1], i);   
//         }

//         if (currWeight < globalMin){
//             currPath[level] = i;
//             visited[i] = true;

//             branch_rec(adj, rootWeight, currWeight, level + 1, currPath);
//         }
//     }
// }


proc tree_branch(in distance: real, adj: []real, in path ) {

    if (path.size == N) {
        distance += adj(path[path.size], path[1]);

        

        if (distance < globalMin) {
            path.append(path[1]);
            globalMin = distance;
            globalMinPath = path;
        }
        return;
    }  

    for i in 1..N {
        
        if (path.contains(i)) {
            continue;
        }
        // writeln("level: ", level, " dist: ", distance, " path ", path);
        var newDistance = distance + adj(path[path.size], i);

        if (newDistance < globalMin) {
            path.append(i);

            tree_branch(newDistance, adj, path);
            path.pop();
        } 
    }
}



var distance: real;
// var level = 1;
var path: list(int);
path.append(4);
path.append(2);
distance = 15.0;

tree_branch(distance, adj, path);

writeln("global best path:\t", globalMinPath);
writeln("global min distance:\t", globalMin);