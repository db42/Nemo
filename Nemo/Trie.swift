//
//  Trie.swift
//  Nemo
//
//  Created by Dushyant Bansal on 29/12/18.
//  Copyright © 2018 Dushyant Bansal. All rights reserved.
//

import Foundation

class Node {
  var dict: [Character: Node] = [:]
  var isLeaf: Bool = false
  
  init() {
  }
}

class Trie {
  var root: Node = Node()
  
  init(words: [String]) {
  }

  
  func add(word: String) {
    var currentNode = root
    for char in word {
      if let node = currentNode.dict[char] {
        currentNode = node
      } else {
        var node = Node()
        currentNode.dict[char] = node
        currentNode = node
      }
    }
    currentNode.isLeaf = true
  }
  
  func find(word: String) -> <#return type#> {
    <#function body#>
  }
}
