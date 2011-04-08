#include <vector>
#include <string>
#include <tr1/memory>
#include <functional>
#include <cassert>
#include <algorithm>


class Trie
{
public:
  
  // @return was added or not
  bool addWord (const std::string & word)
  {
    if (! isValidWord (word))
      {
	return false;
      }
    
    Node::NodeList
      * pCurNodeList = &m_rootNodes;
    
    NodePtr
      pCurrentNode = NodePtr ();
    
    // TODO refactor to extract common search pattern
    for (std::string::const_iterator it = word.begin ()
	   ; it != word.end ()
	   ; ++it)
      {
	assert (pCurNodeList);
        
	pCurrentNode = findChildWithData (*pCurNodeList, *it);
	if (NULL == pCurrentNode)
	  {
	    NodePtr pNode (makeNode (*it));
	    if (NULL == pNode)
	      {
		// oops, break at least, but should do something
		break;
	      }
	    
	    (*pCurNodeList).push_back (pNode);
            
	    pCurrentNode = pNode;
	  }
	
	// drop down a level
	pCurNodeList = &pCurrentNode->nodes;
      }
    
    assert (NULL != pCurrentNode);
    
    if (pCurrentNode)
      {
	pCurrentNode->isWord = true;
      }
    
    assert (isPresent (word));
    
    return true;
  }
  
  bool isPresent (const std::string & word) const
  {
    bool isfound = true;
    
    const Node::NodeList
      * pCurNodeList = &m_rootNodes;
    
    NodePtr
      pCurrentNode = NodePtr();
    
    // TODO refactor to extract common search pattern
    for (std::string::const_iterator it = word.begin ()
                  ; it != word.end ()
	   ; ++it)
      {
	assert (pCurNodeList);
        
	pCurrentNode = findChildWithData (*pCurNodeList, *it);
	if (NULL == pCurrentNode)
	  {
	    isfound = false;
	    break;
	  }
	else
	  {
	    // drop down a level
	    pCurNodeList = &pCurrentNode->nodes;
	  }
      }
    
    return isfound && pCurrentNode && pCurrentNode->isWord;
  }
  
  
private:
  
  struct Node;
  typedef std::tr1::shared_ptr<Node>  NodePtr;
  
  struct Node
  {
    typedef char Data;
    typedef std::vector <NodePtr> NodeList;
    
    Data data;
    bool isWord;
    
    //
    NodeList nodes;
  };
  
  //
  Node::NodeList m_rootNodes;
  
private:
  
  bool isValidWord (const std::string & word) const
  {
    const std::string INVALID_CHARS = " \t\r\n";
    
    return !word.empty() && std::string::npos == word.find_first_of (INVALID_CHARS);
  }
  
  NodePtr findChildWithData (const Node::NodeList & clist
			     , Node::Data data) const
  {
    struct FindByData : std::unary_function<NodePtr, bool>
    {
      Node::Data m_data;
      FindByData (Node::Data data) : m_data(data) {}
      
      result_type operator () (argument_type arg) const
      {
	return arg->data == m_data;
      }
    };
    
    Node::NodeList::const_iterator
      it = std::find_if (clist.begin(), clist.end(), FindByData (data));
    
    return it != clist.end()
      ? *it
      : NodePtr ();
  }
  
  // @return null or new node
  NodePtr makeNode (Node::Data data) const
  {
    NodePtr pNode (new Node ());
    if (NULL != pNode)
      {
	pNode->data = data;
	pNode->isWord = false;
      }
    return pNode;
  }
};


#include <fstream>
#include <string>

// -> trimmed lines

namespace
{
  
  // pretty bad
  std::string trim (const std::string & s)
  {
    if (s.empty())
      {
	return s;
      }
    
    const std::string TRIMMABLE_CHARS = " \t\r\n";
    
    std::string trimmedString = s;
    
    while ( ! trimmedString.empty()
	    && std::string::npos != TRIMMABLE_CHARS.find (trimmedString[0])
	    && std::string::npos != trimmedString.find_first_of (TRIMMABLE_CHARS))
      {
	trimmedString = trimmedString.substr (1);
      }
    
    while ( ! trimmedString.empty()
	    && std::string::npos != TRIMMABLE_CHARS.find (trimmedString[trimmedString.size() - 1])
	    && std::string::npos != trimmedString.find_last_of (TRIMMABLE_CHARS))
      {
	trimmedString = trimmedString.substr (0, trimmedString.size() - 2);
      }
    
    return trimmedString;
  }
  
  std::vector<std::string>
  readWordDictionaryFile (const std::string & filename)
  {
    std::ifstream file (filename.c_str());
    
    std::vector<std::string> lines;
    
    if (! file.is_open())
      {
	// silent
	return lines;
      }
    
    std::string line;
    
    while (std::getline (file, line))
      {
	lines.push_back (trim(line));
      }
    
    return lines;
  }
  
}


int main(int argc, char * argv[])
{
  Trie  trie;
  
  std::vector<std::string>
    lines = readWordDictionaryFile ("words.txt");
  
  for (std::vector<std::string>::const_iterator it = lines.begin()
	 ; it != lines.end()
	 ; ++it)
    {
      trie.addWord (*it);
    }
  
  assert (!trie.isPresent ("QARTER"));
  assert (!trie.isPresent ("CAB"));
  
  return 0;
}

