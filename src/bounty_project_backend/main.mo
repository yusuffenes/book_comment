import Text "mo:base/Text";
import Nat16 "mo:base/Nat16";
import Bool "mo:base/Bool";
import HashMap "mo:base/HashMap";
import Buffer "mo:base/Buffer";
import List "mo:base/List";
import Array "mo:base/Array";
import Trie "mo:base/Trie";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";

// 

actor
{
  type Writer = {
    choiceVisibility:Bool;
    id : Nat32;
    name : Text;
    age : ?Nat16;
    bookName:Text;
    comment:Text;
  };

  type Reader = {
    choiceVisibility:Bool;
    choiceBook:Text;
    choiceWriter:?Text;
  };
  
  type Book = {
    name:Text;
    writer:?Text;
    comment:Text;
  };
  
  var books: HashMap.HashMap<Text, Book> = HashMap.HashMap<Text, Book>(10, Text.equal, Text.hash);
  var writers: HashMap.HashMap<Text, Writer> = HashMap.HashMap<Text, Writer>(10, Text.equal, Text.hash);
  var readers: HashMap.HashMap<Text, Reader> = HashMap.HashMap<Text, Reader>(10, Text.equal, Text.hash);
  var comments: HashMap.HashMap<Text, Text> = HashMap.HashMap<Text, Text>(10, Text.equal, Text.hash);
  // var comments:HashMap.HashMap<Text,Buffer.Buffer<Text>> = HashMap.HashMap<Text,Buffer.Buffer<Text>>(10,Text.equal,Text.hash);
  // var comments: HashMap.HashMap<Text, List.List<Text>> = HashMap.HashMap<Text, List.List<Text>>(10, Text.equal, Text.hash);
  var commentBuffer: Buffer.Buffer<Text> = Buffer.Buffer<Text>(10);
  // var commentList: List.List<Text> = List.List<Text>();
  public func addWriter(writer:Writer) : async () {
    let uploadBookVisible:Book = {
      name= writer.bookName;
      writer= ?writer.name;
      comment= writer.comment;
    };
    let uploadBookInvisible:Book = {
      name= writer.bookName;
      writer= null;
      comment= writer.comment;
    };
    if (writer.choiceVisibility) {
      writers.put(writer.name, writer);
      books.put(writer.bookName, uploadBookVisible);

      if(comments.get(writer.bookName) == null){
        comments.put(writer.bookName,writer.comment);
      }
      else{
        let temp:?Text = comments.get(writer.bookName);
        let text : Text = switch (temp) {
          case (null) { "default" }; 
          case (?t) { t }; 
        };
         comments.put(writer.bookName,text # ", " # writer.comment);
      }
    }
    else {
        books.put(writer.bookName, uploadBookInvisible);
        if(comments.get(writer.bookName) == null){
        comments.put(writer.bookName,writer.comment);
        }
        else{
          let temp:?Text = comments.get(writer.bookName);
          let text : Text = switch (temp) {
            case (null) { "default" }; 
            case (?t) { t }; 
          };
         comments.put(writer.bookName,text # " " # writer.comment);
        }
    };
  };

  public func addReader(reader:Reader) : async () {
    if (reader.choiceVisibility) {
      readers.put(reader.choiceBook, reader);
    }
  };
  //
  public func getCommentsByBookName(bookName: Text):async ?Text{
    let comment: ?Text = comments.get(bookName);
    return comment;

  };

  public func getBookByName(bookName: Text) : async ?Book {
    let book: ?Book = books.get(bookName);
    return book;
  };

  // Deploy da Gorunmeyecek şekilde ayarla
  private  func getWriterByName(writerName: Text) : async ?Writer {
    let writer: ?Writer = writers.get(writerName);
    return writer;
  };

  private func getReaderByName(readerName: Text) : async ?Reader {
    let reader: ?Reader = readers.get(readerName);
    return reader;
  };


  public func getBookByWriterName(writerName: Text) : async ?Book {
    let writer: ?Writer = await getWriterByName(writerName);
    if (writer == null) {
      return null;
    };
    let book: ?Book = books.get(writerName);
    return book;
  };

  

  
}