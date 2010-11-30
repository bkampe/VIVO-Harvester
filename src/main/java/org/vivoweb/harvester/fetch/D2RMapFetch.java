/*******************************************************************************
 * Copyright (c) 2010 Eliza Chan All rights reserved. This program and the accompanying materials are made available
 * under the terms of the new BSD license which accompanies this distribution, and is available at
 * http://www.opensource.org/licenses/bsd-license.html Contributors: Eliza Chan
 ******************************************************************************/
package org.vivoweb.harvester.fetch;

import java.io.IOException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.vivoweb.harvester.util.InitLog;
import org.vivoweb.harvester.util.args.ArgDef;
import org.vivoweb.harvester.util.args.ArgList;
import org.vivoweb.harvester.util.args.ArgParser;
import org.vivoweb.harvester.util.repo.RecordHandler;
import de.fuberlin.wiwiss.d2r.D2rProcessor;
import de.fuberlin.wiwiss.d2r.exception.D2RException;

/**
 * Fetches rdf data using D2RMap
 * @author Eliza Chan (elc2013@med.cornell.edu)
 */
public class D2RMapFetch {
	/**
	 * SLF4J Logger
	 */
	private static Logger log = LoggerFactory.getLogger(D2RMapFetch.class);
	/**
	 * Record Handler to write records to
	 */
	private RecordHandler rh;
	/**
	 * D2RMap config file path
	 */
	private String d2rConfigPath;
	/**
	 * D2RMap output file
	 */
	private String d2rOutputFile;
	
	/**
	 * Constructor
	 * @param output RecordHandler to write data to
	 */
	public D2RMapFetch(RecordHandler output) {
		this.rh = output;
	}
	
	/**
	 * Constructor
	 * @param args commandline arguments
	 * @throws IOException error creating task
	 */
	public D2RMapFetch(String[] args) throws IOException {
		this(new ArgList(getParser(), args));
	}
	
	/**
	 * Constructor
	 * @param opts option set of parsed args
	 * @throws IOException error creating task
	 */
	public D2RMapFetch(ArgList opts) throws IOException {
		this.d2rConfigPath = opts.get("u");
		this.d2rOutputFile = opts.get("s");
		this.rh = RecordHandler.parseConfig(opts.get("o"), opts.getProperties("O"));
	}
	
	/**
	 * Executes the task
	 * @throws IOException error processing
	 */
	public void execute() throws IOException {
		D2rProcessor proc = new D2rProcessor();
		proc.harvesterInit();
		String output;
		try {
			output = proc.processMap("RDF/XML", this.d2rConfigPath);
			this.rh.addRecord(this.d2rOutputFile, output, this.getClass());
		} catch(D2RException e) {
			throw new IOException(e.getMessage(), e);
		}
	}
	
	/**
	 * Get the ArgParser for this task
	 * @return the ArgParser
	 */
	private static ArgParser getParser() {
		ArgParser parser = new ArgParser("D2RMapFetch");
		parser.addArgument(new ArgDef().setShortOption('o').setLongOpt("output").withParameter(true, "CONFIG_FILE").setDescription("RecordHandler config file path").setRequired(true));
		parser.addArgument(new ArgDef().setShortOption('O').setLongOpt("outputOverride").withParameterProperties("RH_PARAM", "VALUE").setDescription("override the RH_PARAM of output recordhandler using VALUE").setRequired(false));
		// d2RMap specific
		parser.addArgument(new ArgDef().setShortOption('u').setLongOpt("d2rMapConfigFile").withParameter(true, "D2RMAP_CONFIG_FILE").setDescription("D2RMap config file path").setRequired(true));
		parser.addArgument(new ArgDef().setShortOption('s').setLongOpt("d2rMapOutputFile").withParameter(true, "D2RMAP_OUTPUT_FILE").setDescription("D2RMap output file").setRequired(true));
		return parser;
	}
	
	/**
	 * Main method
	 * @param args commandline arguments
	 */
	public static void main(String... args) {
		InitLog.initLogger(D2RMapFetch.class);
		log.info(getParser().getAppName()+": Start");
		try {
			new D2RMapFetch(args).execute();
		} catch(IllegalArgumentException e) {
			log.debug(e.getMessage(), e);
			System.out.println(getParser().getUsage());
		} catch(Exception e) {
			log.error(e.getMessage(), e);
		}
		log.info(getParser().getAppName()+": End");
	}
}
