// - The administrator (owner) of the library should be able to add new books and the number of copies in the library.

// - Users should be able to see the available books and borrow them by their id.
// - Users should be able to return books.
// - A user should not borrow more than one copy of a book at a time. The users should not be able to borrow a book more times than the copies in the libraries unless copy is returned.
// - Everyone should be able to see the addresses of all people that have ever borrowed a given book.

pragma solidity >=0.7.0 < 0.9.0;


contract Library{

    struct Book { 
      uint id;
      string name;
      uint numOfCoppies;
    }

    address     private m_owner;
    uint        private m_totalBooks = 0; // used for giving unique book ids
    uint[]      private m_allBookIds; 
    mapping(address => uint)    private m_booksBorrowed;
    mapping(uint => Book)       private m_books;
    mapping(string => uint)     private m_bookIds;
    mapping(uint => mapping(address => bool)) private m_allBorrows;

    constructor() {
        m_owner = msg.sender;
    }

    // PUBLIC
    // Adds a new copy of a book. If book does not exist it will be created. Returns id of the book.
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
        return m_books[bookId].numOfCoppies;
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

    function allAddressesBorrowedBook() public view returns (uint[]) {
        uint[] arr = new uint[]();

    function borrowBook(uint bookId) public {
        assert(bookId > 0);
        assert(m_booksBorrowed[msg.sender] == 0);

        Book memory book = m_books[bookId];
        require(book.id != 0);
        require(book.numOfCoppies > 0);
  
        book.numOfCoppies--;
        m_booksBorrowed[msg.sender] = book.id;
        m_allBorrows[book.id][msg.sender] = true;
    }

    function returnBook() public {
        uint bookBorrowed = m_booksBorrowed[msg.sender];
        require(bookBorrowed > 0);
        Book memory book = m_books[bookBorrowed];
        require(book.id > 0);

        book.numOfCoppies++;
        m_booksBorrowed[msg.sender] = 0;
    }


    // PRIVATE
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