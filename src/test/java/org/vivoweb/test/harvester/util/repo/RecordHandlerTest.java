/*******************************************************************************
 * Copyright (c) 2010 Christopher Haines, Dale Scheppler, Nicholas Skaggs, Stephen V. Williams. All rights reserved.
 * This program and the accompanying materials are made available under the terms of the new BSD license which
 * accompanies this distribution, and is available at http://www.opensource.org/licenses/bsd-license.html Contributors:
 * Christopher Haines, Dale Scheppler, Nicholas Skaggs, Stephen V. Williams - initial API and implementation
 ******************************************************************************/
package org.vivoweb.test.harvester.util.repo;

import java.io.IOException;
import java.util.ArrayList;
import junit.framework.TestCase;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.vivoweb.harvester.util.InitLog;
import org.vivoweb.harvester.util.repo.JDBCRecordHandler;
import org.vivoweb.harvester.util.repo.JenaRecordHandler;
import org.vivoweb.harvester.util.repo.MapRecordHandler;
import org.vivoweb.harvester.util.repo.RDBJenaConnect;
import org.vivoweb.harvester.util.repo.Record;
import org.vivoweb.harvester.util.repo.RecordHandler;
import org.vivoweb.harvester.util.repo.RecordMetaData;
import org.vivoweb.harvester.util.repo.TextFileRecordHandler;

/**
 * @author Christopher Haines (hainesc@ctrip.ufl.edu)
 */
public class RecordHandlerTest extends TestCase {
	/**
	 * SLF4J Logger
	 */
	private static Logger log = LoggerFactory.getLogger(RecordHandlerTest.class);
	/** */
	private RecordHandler rh;
	
	@Override
	protected void setUp() throws Exception {
		InitLog.initLogger(RecordHandlerTest.class);
		this.rh = null;
	}
	
	@Override
	protected void tearDown() throws Exception {
		ArrayList<String> ids = new ArrayList<String>();
		// Get list of record ids
		for(Record r : this.rh) {
			/*
			 * Do not do this: this.rh.delRecord(r.getID()); since that will generate ConcurrentModificationException
			 */
			ids.add(r.getID());
		}
		// Delete records for all ids
		for(String id : ids) {
			this.rh.delRecord(id);
		}
		this.rh.close();
	}
	
	/**
	 * Test method for
	 * {@link org.vivoweb.harvester.util.repo.JDBCRecordHandler#JDBCRecordHandler(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String)
	 * JDBCRecordHandler(String jdbcDriverClass, String connLine, String username, String password, String tableName,
	 * String dataFieldName)}.
	 */
	public void testJDBCAddRecord() {
		log.info("BEGIN testJDBCAddRecord");
		try {
			this.rh = new JDBCRecordHandler("org.h2.Driver", "jdbc:h2:mem:TestRH-JDBC", "sa", "", "testdb", "data");
			runBattery();
		} catch(Exception e) {
			log.error(e.getMessage(), e);
			fail(e.getMessage());
		}
		log.info("END testJDBCAddRecord");
	}
	
	/**
	 * Test method for
	 * {@link org.vivoweb.harvester.util.repo.TextFileRecordHandler#TextFileRecordHandler(java.lang.String)
	 * TextFileRecordHandler(String fileDir)}.
	 */
	public void testTextFileAddRecord() {
		log.info("BEGIN testTextFileAddRecord");
		try {
			this.rh = new TextFileRecordHandler("tmp://testTFRH");
			runBattery();
		} catch(Exception e) {
			log.error(e.getMessage(), e);
			fail(e.getMessage());
		}
		log.info("END testTextFileAddRecord");
	}
	
	/**
	 * Test method for {@link org.vivoweb.harvester.util.repo.MapRecordHandler#MapRecordHandler() MapRecordHandler()}.
	 */
	public void testMapAddRecord() {
		log.info("BEGIN testMapAddRecord");
		try {
			this.rh = new MapRecordHandler();
			runBattery();
		} catch(Exception e) {
			log.error(e.getMessage(), e);
			fail(e.getMessage());
		}
		log.info("END testMapAddRecord");
	}
	
	/**
	 * Test method for
	 * {@link org.vivoweb.harvester.util.repo.JenaRecordHandler#JenaRecordHandler(org.vivoweb.harvester.util.repo.JenaConnect, java.lang.String)
	 * JenaRecordHandler(JenaConnect jena, String dataFieldType)}.
	 */
	public void testJenaAddRecord() {
		log.info("BEGIN testJenaAddRecord");
		try {
			this.rh = new JenaRecordHandler(new RDBJenaConnect("jdbc:h2:mem:TestRH-Jena;MODE=HSQLDB", "sa", "", "HSQLDB", "org.h2.Driver"), "http://localhost/jenarecordhandlerdemo#data");
			runBattery();
		} catch(Exception e) {
			log.error(e.getMessage(), e);
			fail(e.getMessage());
		}
		log.info("END testJenaAddRecord");
	}
	
	/**
	 * @throws IOException error
	 */
	private void runBattery() throws IOException {
		runAddRecord();
		runNoModRecord();
		runModRecord();
		runDelRecord();
	}
	
	/**
	 * @throws IOException error
	 */
	private void runAddRecord() throws IOException {
		log.info("Start adding test");
		String recID = "test1";
		String recData = "MyDataIsReally Awesome";
		String recDataMD5 = RecordMetaData.md5hex(recData);
		assertTrue(this.rh.addRecord(recID, recData, this.getClass()));
		Record r = this.rh.getRecord(recID);
		log.info("Record Data: " + r.getData());
		String rDataMD5 = RecordMetaData.md5hex(r.getData());
		assertEquals(recData.trim(), r.getData().trim());
		assertEquals(recDataMD5, rDataMD5);
		log.info("End adding test");
	}
	
	/**
	 * @throws IOException error
	 */
	private void runNoModRecord() throws IOException {
		log.info("Start no mod test");
		String recID = "test1";
		String recData = "MyDataIsReally Awesome";
		assertFalse(this.rh.addRecord(recID, recData, this.getClass()));
		log.info("End no mod test");
	}
	
	/**
	 * @throws IOException error
	 */
	private void runModRecord() throws IOException {
		log.info("Start mod test");
		String recID = "test1";
		String recData = "MyDataIsReally Awesome - Again!";
		assertTrue(this.rh.addRecord(recID, recData, this.getClass()));
		log.info("End mod test");
	}
	
	/**
	 * @throws IOException error
	 */
	private void runDelRecord() throws IOException {
		log.info("Start del test");
		String recID = "test1";
		this.rh.delRecord(recID);
		try {
			this.rh.getRecord(recID);
			fail("Illegal Record ID Request Should Throw IllegalArgumentException!");
		} catch(IllegalArgumentException e) {
			// ignore since this is the expected behavior
		}
		log.info("End del test");
	}
	
}
