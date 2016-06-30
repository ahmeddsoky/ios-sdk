/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import XCTest
import RetrieveAndRankV1

class RetrieveAndRankTests: XCTestCase {
    
    private var retrieveAndRank: RetrieveAndRank!
    private let timeout: NSTimeInterval = 30.0
    
    // MARK: - Test Configuration
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        instantiateRetrieveAndRank()
    }
    
    /** Instantiate Retrieve and Rank instance. */
    func instantiateRetrieveAndRank() {
        let bundle = NSBundle(forClass: self.dynamicType)
        guard
            let file = bundle.pathForResource("Credentials", ofType: "plist"),
            let credentials = NSDictionary(contentsOfFile: file) as? [String: String],
            let username = credentials["RetrieveAndRankUsername"],
            let password = credentials["RetrieveAndRankPassword"]
            else {
                XCTFail("Unable to read credentials.")
                return
        }
        retrieveAndRank = RetrieveAndRank(username: username, password: password)
    }
    
    /** Fail false negatives. */
    func failWithError(error: NSError) {
        XCTFail("Positive test failed with error: \(error)")
    }
    
    /** Fail false positives. */
    func failWithResult<T>(result: T) {
        XCTFail("Negative test returned a result.")
    }
    
    /** Wait for expectations. */
    func waitForExpectations() {
        waitForExpectationsWithTimeout(timeout) { error in
            XCTAssertNil(error, "Timeout")
        }
    }
    
    // MARK: - Helper Functions
    
    /** Create a new Solr cluster. */
    private func createSolrCluster(clusterName: String, size: String? = nil) -> SolrCluster? {
        let description = "Create a new Solr Cluster."
        let expectation = expectationWithDescription(description)
        
        var solrCluster: SolrCluster?
        retrieveAndRank.createSolrCluster(clusterName, size: size, failure: failWithError) {
            cluster in
            
            solrCluster = cluster
            expectation.fulfill()
        }
        waitForExpectations()
        return solrCluster
    }
    
    /** Delete a Solr cluster. */
    private func deleteSolrCluster(clusterID: String) {
        let description = "Delete the Solr Cluster with the given ID."
        let expectation = expectationWithDescription(description)
        
        retrieveAndRank.deleteSolrCluster(clusterID, failure: failWithError) {
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    // MARK: - Positive Tests
    
    /** List all of the Solr clusters associated with this service instance. */
    func testGetSolrClusters() {
        let description = "Get all of the Solr clusters associated with this instance."
        let expectation = expectationWithDescription(description)
        
        retrieveAndRank.getSolrClusters(failWithError) { clusters in
            
            XCTAssertEqual(clusters.count, 0)
            expectation.fulfill()
        }
        waitForExpectations()
    }
    
    /** Create and then delete a new Solr cluster. */
    func testCreateAndDeleteSolrCluster() {
        guard let solrCluster = createSolrCluster("swift-sdk-unit-test-solr-cluster") else {
            XCTFail("Failed to create the Solr cluster.")
            return
        }
        XCTAssertEqual(solrCluster.solrClusterName, "swift-sdk-unit-test-solr-cluster")
        XCTAssertNotNil(solrCluster.solrClusterID)
        XCTAssertNotNil(solrCluster.solrClusterSize)
        XCTAssertNotNil(solrCluster.solrClusterStatus)
        
        deleteSolrCluster(solrCluster.solrClusterID)
    }
    
    // MARK: - Negative Tests
    
    /** Create a Solr cluster with an invalid size. */
    func testCreateSolrClusterWithInvalidSize() {
        let description = "Delete a Solr cluster when passing an invalid Solr cluster ID."
        let expectation = expectationWithDescription(description)
        
        let failure = { (error: NSError) in
            XCTAssertEqual(error.code, 400)
            expectation.fulfill()
        }
        
        retrieveAndRank.createSolrCluster(
            "swift-sdk-unit-test-solr-cluster",
            size: "100",
            failure: failure,
            success: failWithResult)
        
        waitForExpectations()
    }
    
    /** Attempt to delete a Solr cluster by passing an invalid Solr cluster ID. */
    func testDeleteSolrClusterWithBadID() {
        let description = "Delete a Solr cluster when passing an invalid Solr cluster ID."
        let expectation = expectationWithDescription(description)
        
        let failure = { (error: NSError) in
            XCTAssertEqual(error.code, 400)
            expectation.fulfill()
        }
        
        retrieveAndRank.deleteSolrCluster(
            "abcde-12345-fghij-67890",
            failure: failure,
            success: failWithResult)
        
        waitForExpectations()
    }
    
//    func testDeleteSolrClusterWithInaccessibleID() {
//        let description = "delete invalid"
//        let expectation = expectationWithDescription(description)
//        
//        let failure = { (error: NSError) in
//            XCTAssertEqual(error.code, 403)
//            expectation.fulfill()
//        }
//        
//        retrieveAndRank.deleteSolrCluster(
//            "sc19cac12e_3587_4510_820d_87945c51a3f9",
//            failure: failure,
//            success: failWithResult)
//        
//        waitForExpectations()
//    }
}