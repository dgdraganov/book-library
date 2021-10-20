// - The administrator (owner) of the library should be able to add new books and the number of copies in the library.
// - Users should be able to see the available books and borrow them by their id.
// - Users should be able to return books.
// - A user should not borrow more than one copy of a book at a time. The users should not be able to borrow a book more times than the copies in the libraries unless copy is returned.
// - Everyone should be able to see the addresses of all people that have ever borrowed a given book.

pragma solidity >=0.7.0 < 0.9.0;

contract Library{
    using IterableMapping for IterableMapping.Map;

    struct Book { 
      uint id;
      string name;
      uint numOfCoppies;
    }

    address     private m_owner;
    uint        private m_totalBooks = 0; // used for giving unique book ids
    uint[]      private m_allBookIds; 
    mapping(address => mapping(uint => bool))    private m_bookBorrowed;
    mapping(uint => Book)       private m_books;
    mapping(string => uint)     private m_bookIds;
    mapping(uint => IterableMapping.Map) private m_allBorrows;

    constructor() {
        m_owner = msg.sender;
    }

    // PUBLIC

    // Adds a new copy of a book. If book does not exist it will be created. 
    // Returns the id of the book.
    function addBookCopy(string memory bookName) public returns (uint){
        require(msg.sender == m_owner);
        
        if (!_bookExists(bookName)){
            _addNewBook(bookName);
        }
        
        uint bookId = m_bookIds[bookName];
        m_books[bookId].numOfCoppies++;
        
        return bookId;
    }

    function checkNumberOfCopies(uint bookId) public view returns (uint){
        Book memory book = _getBook(bookId);
        return book.numOfCoppies;
    }

    function getAllBooks() public view returns (Book[] memory){
        uint arrLen = m_allBookIds.length;
        Book[] memory books = new Book[](arrLen);
        
        for(uint i = 0; i < m_allBookIds.length; i++){
            uint id = m_allBookIds[i];
            books[i] = m_books[id];
        }
        return books;
    }

    function allAddressesBorrowedBook(uint bookId) public view returns (address[] memory) {
        IterableMapping.Map storage map = m_allBorrows[bookId];
        uint mapLen = map.size();
        address[] memory result = new address[](mapLen);

        for (uint i = 0; i < mapLen; i++) {
            address addr = map.getKeyAtIndex(i);
            result[i] = addr;
        }
        return result;
    }

    function borrowBook(uint bookId) public {
        Book memory book = _getBook(bookId);
        require(book.numOfCoppies > 0);

        assert(!m_bookBorrowed[msg.sender][book.id]);
  
        book.numOfCoppies--;
        m_bookBorrowed[msg.sender][book.id] = true;
        m_allBorrows[book.id].set(msg.sender, true); 
    }

    function returnBook(uint bookId) public {
        Book memory book = _getBook(bookId);
        require(book.numOfCoppies > 0);

        assert(m_bookBorrowed[msg.sender][book.id]);

        book.numOfCoppies++;
        m_bookBorrowed[msg.sender][book.id] = false;
    }

    // PRIVATE
    function _getBook(uint bookId) private view returns (Book memory){
        assert(bookId > 0);
        Book memory book = m_books[bookId];
        require(book.id != 0);
        return book;
    }

    function _addNewBook(string memory bookName) private {
        uint bookId = m_totalBooks++;
        Book memory newBook = Book(bookId, bookName, 0);
        m_books[bookId] = newBook;
        m_bookIds[bookName] = bookId;
        m_allBookIds.push(bookId);
    }

    function _bookExists(string memory bookName) private view returns (bool) {
        
        if (m_bookIds[bookName] == 0) {
            return false;
        }
        return true;
    }
}

library IterableMapping {
    // Iterable mapping from address to uint;
    struct Map {
        address[] keys;
        mapping(address => bool) values;
        mapping(address => uint) indexOf;
        mapping(address => bool) inserted;
    }

    function get(Map storage map, address key) public view returns (bool) {
        return map.values[key];
    }

    function getKeyAtIndex(Map storage map, uint index) public view returns (address) {
        return map.keys[index];
    }

    function size(Map storage map) public view returns (uint) {
        return map.keys.length;
    }

    function set(
        Map storage map,
        address key,
        bool val
    ) public {
        if (map.inserted[key]) {
            map.values[key] = val;
        } else {
            map.inserted[key] = true;
            map.values[key] = val;
            map.indexOf[key] = map.keys.length;
            map.keys.push(key);
        }
    }

    function remove(Map storage map, address key) public {
        if (!map.inserted[key]) {
            return;
        }

        delete map.inserted[key];
        delete map.values[key];

        uint index = map.indexOf[key];
        uint lastIndex = map.keys.length - 1;
        address lastKey = map.keys[lastIndex];

        map.indexOf[lastKey] = index;
        delete map.indexOf[key];

        map.keys[index] = lastKey;
        map.keys.pop();
    }
}