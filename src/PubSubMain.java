import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

import org.jivesoftware.smack.*;
import org.jivesoftware.smack.packet.*;
import org.jivesoftware.smackx.pubsub.*;



public class PubSubMain {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		
		if ( args.length != 3 ){
			System.out.println("Usage : groupid byname songdetails");
			return;
		}
		String gid;
		String song;
		String from;
		
		gid = args[0];
		song = args[2];
		from = args[1];
		
		song = song.replace("&","&amp;");
		song = song.replace("<", "&lt;");
		song = song.replace(">", "&gt;");
		song = song.replace("'", "&apos;");
		System.out.println("Command = " + gid + " " + song + " " + from);
		
		// TODO Auto-generated method stub
		SmackConfiguration.setConfigFileUrl("file:///home/ashok/workspace/xmppPubSub/src/smack-config.xml", null);
		
		// Create a connection to the jabber.org server on a specific port.
		ConnectionConfiguration config = new ConnectionConfiguration("localhost", 5222, "listenpals.com");
		Connection conn = new XMPPConnection(config);
		try {
			conn.connect();
			conn.login("ashok", "ashok");
		} catch (Exception e) {
			System.out.println("Error connect : " + e.toString());
		}

		// Create a new presence. Pass in false to indicate we're unavailable.
		//Presence presence = new Presence(Presence.Type.unavailable);
		//presence.setStatus("Gone fishing");
		// Send the packet (assume we have a Connection instance called "con").
		//conn.sendPacket(presence);
		
	      // Create a pubsub manager using an existing Connection
	      PubSubManager mgr = new PubSubManager(conn);
	      LeafNode leaf;

	      
	      
	      try {
	    	   //leaf = mgr.createNode("dogsgroup3");
	    	  leaf = mgr.getNode(gid);
	    	  
	      }catch (Exception e)
	      {
	    	  leaf = null;
	      }
	   // Create the node
	      try {
	    	  //leaf = mgr.createNode("dogsgroup3");
	    	  if ( leaf == null ) {
	    		  ConfigureForm form = new ConfigureForm(FormType.submit);
	    	      form.setAccessModel(AccessModel.open);
	    	      form.setDeliverPayloads(true);
	    	      form.setPersistentItems(true);
	    		  System.out.println("Null found");
	    		  leaf = mgr.createNode(gid);
	    	  
	    		  leaf.sendConfigurationForm(form);
	    	  }
	    	  // Publish an Item with payload
	    	  DateFormat df = new SimpleDateFormat("yyyyMMdd'T'HH:mm:ss");
	    	  df.setTimeZone(TimeZone.getTimeZone("UTC"));
	    	  Date dt = new Date(System.currentTimeMillis());
	    	  
	    	  String payload =  "<song xmlns=\"pubsub:gid:song\" timestamp=\"" + df.format(dt) + "\"><from>" + 
	    			  			from + "</from><title>" + song + "</title></song>";
	    	  
	    	  //String payload = "babhs";
	    	  System.out.println(payload);
	    	  
	          leaf.publish(new PayloadItem("nowplaying:" + System.currentTimeMillis(), 
	              new SimplePayload(from, "stage:pubsub:simple" , payload)));
	          
	      } catch (Exception e) {
	    	  System.out.println("Error create node: " + e.toString());
	      }
	      
	     
	}

}
