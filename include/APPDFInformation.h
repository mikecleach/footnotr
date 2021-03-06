
/*
 *
 * iANNOTATE PDF SDK
 * PROPERTY OF BRANCHFIRE, INC
 * (C) COPYRIGHT 2010-13, ALL RIGHTS RESERVED
 *
 * BRANCHFIRE, INC., CONFIDENTIAL INFORMATION
 *
 * LIBRARY ACCESS AND DISTRIBUTION ARE SUBJECT TO LICENSE AGREEMENT
 * UNAUTHORIZED USE, REPRODUCTION, OR DISTRIBUTION IS PROHIBITED
 *
 * PLEASE CONTACT LIBRARY-SUPPORT@BRANCHFIRE.COM IF YOU HAVE ANY QUESTIONS REGARDING USE OR DISTRIBUTION
 *
 *
 */


#import "APPDF.h"


@class APPDFInformationPrivate;
@class APSearchPrivate;



/**
 * Provides information about a PDF file. This information is cached
 * in a disk file, which is available in the path attribute. PDF
 * Information files are generated by the APPDFProcessor driver class,
 * and are also used as an on-disk cache for user annotations.
 *
 * \sa APPDFProcessor
 */
@interface APPDFInformation : NSObject
{
@private
    APPDFInformationPrivate *m_private;
}


/**
 * The full path to the information file.
 */
@property(readonly) NSString *path;


/**
 * The APPDFInformation version of this information file.
 */
@property(readonly) NSUInteger version;


/**
 * Used to determine if this PDF file has had its information
 * processed.
 *
 * \return <code>YES</code> if the information has been processed for
 * this PDF, <code>NO</code> if processing is still required.
 *
 * \sa APPDFProcessor
 */
@property(readonly) BOOL isProcessed;


/**
 * Used to determine if the information for this PDF matches the PDF
 * file on disk. The file is modified whenever any annotations are
 * added, deleted, or modified.
 *
 * \return <code>YES</code> if the file is modified, <code>NO</code>
 * if the PDF file on disk is up-to-date.
 *
 * \sa APPDFProcessor
 */
@property(readonly) BOOL isModified;


/**
 * \return The root APOutlineElement for this document;
 * <code>nil</code> if this document contains no PDF outline.
 */
@property(readonly) APOutlineElement *outlineRoot;


/**
 * Use to verify the validity and obtain the version of the
 * information file at the specified path.
 *
 * \return The version of the information file, or 0 if the file is
 * not a valid APPDFInformatio file.
 */
+(NSUInteger)versionOfInformationAtPath:(NSString *)path;


/**
 * Designated initializer. The file at <code>basePath</code> must
 * exist and point to a valid PDF Information file (created using the
 * APPDFProcessor class).
 * 
 * \return The APPDFInformation object, or <code>nil</code> if the
 * file at basePath does not exist or is not a valid PDF Information
 * file.
 */
-(id)initWithPath:(NSString *)basePath;

/**
 * Initializes the PDF Information using an in-memory database
 * instead of a file on disk.
 */
-(id)initAsMemoryDatabase;


/**
 * Used to access all annotations in the document. NOTE: this will
 * load all data from all annotations from the database -- including
 * things like all of the point data for APInk paths -- so this method
 * can become slow when the number of annotations in a document
 * grows. Please use with care.
 *
 * \return An array of APAAnnotation objects containing all
 * user annotations in the document.
 *
 * \sa APPDFInformation::numberOfUserAnnotations
 */
-(NSArray *)allUserAnnotations;


/** 
 * Used to access all annotations on a single page of the document.
 *
 * \param page The 0-based page index of the PDF document.
 *
 * \return An NSArray of APAAnnotation objects for the annotations on
 * the indicated page of the document.
 */
-(NSArray *)userAnnotationsOnPage:(NSUInteger)page;


/** 
 * Used to determine the number of annotations in the document.
 *
 * \return The number of user annotations in the document.
 */
-(NSUInteger)numberOfUserAnnotations;


/**
 * Used to access all bookmarks in the document.
 *
 * \return An array of APABookmark objects containing all
 * bookmarks in the document.
 */
-(NSArray *)bookmarks;


/**
 * Used to access all links in the document.
 *
 * \return An array of APALink objects containing all
 * links in the document.
 */
-(NSArray *)links;


/**
 * Used to programmatically add a new annotation object to the
 * document. Note that annotation must be a client-created annotation
 * object with all required properties set. (For updating existing
 * annotation objects, use APPDFInformation::updateUserAnnotation:)
 *
 * \return YES if the annotation was successfully added to the
 * document, NO otherwise.
 */
-(BOOL)addUserAnnotation:(APAnnotation *)annotation;


/**
 * Used to persist programmatic changes to an annotation object. Note
 * that annotation must be an annotation object returned from this
 * APPDFInformation object; for adding new annotation objects, use
 * APPDFInformation::addUserAnnotation:
 *
 * \return YES if the annotation was successfully updated, NO
 * otherwise.
 */
-(BOOL)updateUserAnnotation:(APAnnotation *)annotation;


/**
 * Used to programmatically delete an annotation. Note that annotation
 * must be an annotation object returned from this APPDFInformation
 * object.
 *
 * \return YES if the annotation was successfully deleted, NO
 * otherwise.
 */
-(BOOL)removeAnnotation:(APAnnotation *)annot;


/**
 * Used to programmatically remove all annotations from this document.
 *
 * \return YES if the annotations were successfully deleted, NO
 * otherwise.
 */
-(BOOL)removeAllAnnotations;


/**
 * Used to obtain an integer identifier for the supplied annotation
 * object. This identifier will be unique across the document and
 * persistent across sessions for disk-based information files.
 *
 * \param annot The annotation whose unique identifier to
 * obtain. Please note that this annotation must be saved to this
 * information file: i.e., it must have been created using the user
 * interface or added programatically to this document via
 * APPDFInformation::addUserAnnotation:
 *
 * \return An integer uniquely identifying this annotation in this
 * document.
 *
 * \sa APPDFInformation::annotationForIdentifier:
 */
-(NSUInteger)identifierForAnnotation:(APAnnotation *)annot;


/**
 * Used to look up annotation objects by their unique identifier.
 *
 * \param identifier The integer identifier for an annotation in this
 * document, obtained from a previous call to
 * APPDFInformation::identifierForAnnotation:.
 *
 * \return The annotation object associated to this identifier.
 *
 * \sa APPDFInformation::identifierForAnnotation:
 */
-(APAnnotation *)annotationForIdentifier:(NSUInteger)identifier;


/**
 * Used to determine if the PDF can be searched.  
 *
 * \return <code>YES</code> if the PDF has been processed and has searchable text.
 *
 * \sa APPDFInformation::isProcessed
 */
-(BOOL)isSearchable;

/**
 * Returns all the text in the PDF an array of lines.
 * 'Line' boundaries are determined by the PDF, and may not correspond
 * with their visual appearance on the page.
 *
 * The PDF should be processed before using this method.
 *
 * \sa APPDFInformation::isProcessed
 * \sa APPDFProcessor
 */
-(NSArray *)allText;

/**
 * Returns the text on the given page as an array of lines.
 * 'Line' boundaries are determined by the PDF, and may not correspond
 * with their visual appearance on the page.
 *
 * The PDF should be processed before using this method.
 *
 * \sa APPDFInformation::isProcessed
 * \sa APPDFProcessor
 */
-(NSArray *)textOnPage:(NSUInteger)page;

/**
 * Used to determine if the PDF has any available text.  If the PDF
 * document has not yet been processed, this will still return YES if
 * any characters have been discovered via live processing the 
 * currently-active page range (unless the 
 * APPDFViewOptions::liveProcessingDisabled is turned on).
 *
 * Note that this method is appropriate for checking if markup
 * annotation tools (such as highlighter) and text selection
 * functionality should be enabled. This <i>alone</i> should 
 * <b>not</b> be used to enable search functionality; 
 * that requires that the PDF is processed, so 
 * APPDFInformation::isProcessed must also be YES in this case.
 * However, we recommend using the new (as of 2.4) APPDFInformation::isSearchable
 * method instead.
 *
 * \return <code>YES</code> if any text was detected in the
 * PDF document. Note that some PDF files that appear to be textual
 * may not have embedded text; for example, if a scanned document has
 * not been OCR'd.
 *
 * \sa APPDFInformation::isSearchable
 * \sa APPDFInformation::hasTextOnPage
 * \sa APPDFInformation::isProcessed
 * \sa APPDFProcessor
 */
-(BOOL)hasText;


/**
 * Used to determine if there is any selectable text on a single page
 * of the PDF.  Similar to APPDFInformation::hasText, but restricts the 
 * query to the indicated page.  If the PDF document has not yet been 
 * processed, this will still return YES if any characters have been 
 * discovered via live processing the specified page range (unless the 
 * APPDFViewOptions::liveProcessingDisabled is turned on).
 *
 * Note that this method is appropriate for checking if markup
 * annotation tools (such as highlighter) and text selection
 * functionality should be enabled. This <i>alone</i> should <b>not</b> be 
 * used to enable search functionality for a single page; 
 * that requires that the PDF is processed, so APPDFInformation::isProcessed 
 * must also be YES in this case.
 *
 * \return <code>YES</code> if any text was detected in the
 * \param page The 0-based page index on which to check for vector
 * text.
 *
 * \return <code>YES</code> if any text was detected on the specified page
 * of the PDF document. Note that some PDF files that appear to be textual
 * may not have embedded text; for example, if a scanned document has
 * not been OCR'd.
 *
 * \sa APPDFInformation::isSearchable
 * \sa APPDFInformation::hasText:
 * \sa APPDFInformation::isProcessed
 * \sa APPDFProcessor
 */
-(BOOL)hasTextOnPage:(NSUInteger)page;


/**
 * Used to determine if there are any annotations for the document.
 *
 * \return <code>YES</code> if the document has any annotations.
 */
-(BOOL)hasUserAnnotations;


/**
 * Used to determine if there are any bookmarks in the document.
 *
 * \return <code>YES</code> if the document has any bookmarks.
 */
-(BOOL)hasBookmarks;


/**
 * Used to determine if there are any links in the document.
 *
 * \return <code>YES</code> if the document has any links.
 */
-(BOOL)hasLinks;


/**
 * Used to determine if the document has a PDF Outline.
 *
 * \return <code>YES</code> if the document has a PDF Outline.
 */
-(BOOL)hasPDFOutline;


/**
 * Used to perform a full-text search of the document. The parameter
 * is an APSearch helper object, which includes an APSearchRequest
 * object describing the search query and specifying various search
 * options, and an APPDFSearchDelegate object which is used to return
 * search result data.
 *
 * A search operation can take some time, especially on large
 * documents, so it is highly recommended that this method only be
 * called on a background thread.
 *
 * \return <code>YES</code> if one or more results were found that match the query.
 *
 * \sa APSearch
 * \sa APSearchRequest
 * \sa APPDFSearchDelegate
 */
-(BOOL)performSearch:(APSearch *)query;


/**
 * Used to update the path of this information file after it is renamed
 * or moved.
 *
 * \param newBasePath The full new path for this information file.
 */
-(void)updateBasePath:(NSString *)newBasePath;


/**
 * Used to export all user annotations in this information file to XML
 * string. This will block during writing, so it is recommended that
 * this task be performed on a background thread.
 *
 * \param outputStream The NSOutputStream to which the XML annotation
 * data will be written. The stream must be initialized and optionally
 * opened. The stream will not be closed upon return; it is up to the
 * client to properly close the stream after the export operation.
 *
 * \param includeBookmarks If YES, user-added bookmarks will be included 
 * as if they were annotations.
 *
 * \return <code>YES</code> if the export succeeded.
 */
-(BOOL)exportAnnotationXMLToStream:(NSOutputStream *)outputStream includeBookmarks:(BOOL)includeBookmarks;


/**
 * Similar to "exportAnnotationXMLToStream:", but allows for a single
 * annotation to be exported, instead of all of the user annotations
 * in the document.
 *
 * \param outputStream The NSOutputStream to which the XML annotation
 * data will be written. The stream must be initialized and optionally
 * opened. The stream will not be closed upon return; it is up to the
 * client to properly close the stream after the export operation.
 *
 * \return <code>YES</code> if the export succeeded.
 */
-(BOOL)exportSingleAnnotationXML:(APAnnotation *)annotation toStream:(NSOutputStream *)outputStream;


/**
 * Used to import annotations in XML format into this information
 * file. Please note that it is up to the client to make sure that the
 * imported annotation data are valid -- and, in general, annotations
 * will only be accurately placed on the same document from whence
 * they originated. Importing annotations from a different base
 * document can cause problems and even crashes (for example, if an
 * annotation is on a page index that is too large for the host
 * document).
 *
 * This is primarily intended to be used to offer external storage of
 * annotations (eg: on a remote server, or encrypted store) outside
 * the document.
 *
 * The XML format must match the format generated by
 * "exportAnnotationXMLToStream:", provided as a single XML annotation
 * or a sequence of tags inside of an "annotations" parent tag.
 *
 * \param inputStream The NSInputStream from which the XML annotation
 * data will be read.
 *
 * \return <code>YES</code> if the import succeeded.
 */
 -(BOOL)importAnnotationXMLFromStream:(NSInputStream *)inputStream;






@end




/**
 * Delegate protocol for document search notifications.
 *
 * \sa APSearch
 * \sa APPDFInformation::performSearch:
 */
@protocol APPDFSearchDelegate <NSObject>


@optional


/**
 * Called when the search has found a result.
 *
 * \param searchRequest The request object for this search
 * \param result The result object with information about the match
 */
-(void)search:(APSearchRequest *)searchRequest foundResult:(APSearchResult *)result;

/**
 * Called every time a page has finished searching.
 *
 * \param searchRequest The request object for this search
 * \param pageIndex The 0-based index of the page that was searched
 */
-(void)search:(APSearchRequest *)searchRequest didSearchPage:(NSUInteger)pageIndex;

/**
 * Called when the search is complete
 *
 * \param searchRequest The request object for this search
 */
-(void)searchDidFinish:(APSearchRequest *)searchRequest;


@end



/**
 * Helper object to encapsulate a search request and delegate for callback notifications.
 */
@interface APSearch : NSObject
{
@private
    APSearchPrivate *m_private;
}


/**
 * Initializer for creating the search object.
 *
 * \param request The data object desribing the search to be performed
 * \param delegate An APPDFSearchDelegate object for notification callbacks
 */
-(id)initWithSearchRequest:(APSearchRequest *)request delegate:(id<APPDFSearchDelegate>)delegate;


@end




